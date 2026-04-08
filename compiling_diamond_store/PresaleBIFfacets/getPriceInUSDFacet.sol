// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract getPriceInUSDFacet is Ownable {
    using SafeMath for uint256;

    event BuyToken(
        address buyer,
        uint256 amountOut,
        uint256 amountIn,
        string buyFrom,
        string chain,
        string hashBSC
    );
    event Stake(address buyer, uint256 amount);
    function getPriceInUSD() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.stages[ds.currentStage].priceInUSDStage;
    }
    function getTokenAmountETH(
        uint256 amountEth
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 lastEthPriceByUSD = getLatestPriceEthPerUSD();
        return (amountEth * lastEthPriceByUSD) / getPriceInUSD(ds.currentStage);
    }
    function getLatestPriceEthPerUSD() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (, int256 price, , , ) = ds.aggregatorETHInterface.latestRoundData();
        price = (price * (10 ** 10));
        return uint256(price);
    }
    function buyTokenByEth(address refOf) external payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 ethAmount = msg.value;
        uint256 amount = getTokenAmountETH(ethAmount);
        require(amount > 0, "Amount is zero");
        require(ds.inSell, "Invalid time for buying");
        // if (ethAmount > msg.sender.balance) {
        //     revert();
        // }
        (ds._wallet).transfer((ethAmount * 950) / 1000);
        buyToken(
            msg.sender,
            msg.sender,
            amount,
            ethAmount,
            "ETH",
            "ETH",
            refOf,
            ""
        );
    }
    function buyToken(
        address buyer,
        address transferTo,
        uint256 amount,
        uint256 amountIn,
        string memory buyFrom,
        string memory chain,
        address refOf,
        string memory hashBSC
    ) private returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyers[transferTo] = ds.buyers[transferTo].add(amount);
        ds.stages[ds.currentStage].raised = ds
            .stages[ds.currentStage]
            .raised
            .add(amount);
        checkNextStage();
        if (ds.inRefReward) {
            if (ds.refOfs[buyer] == address(0) && refOf != address(0)) {
                ds.refOfs[buyer] = refOf;
            }
            if (ds.refOfs[buyer] != address(0)) {
                if (address(this).balance == (amountIn * 50) / 1000) {
                    payable(refOf).transfer((amountIn * 50) / 1000);
                } else {
                    ds.usdtToken.transferFrom(
                        msg.sender,
                        refOf,
                        (amountIn * 50) / 1000
                    );
                }
            } else {
                if (address(this).balance == (amountIn * 50) / 1000) {
                    payable(ds._wallet).transfer((amountIn * 50) / 1000);
                } else {
                    ds.usdtToken.transferFrom(
                        msg.sender,
                        ds._wallet,
                        (amountIn * 50) / 1000
                    );
                }
            }
        }

        emit BuyToken(buyer, amount, amountIn, buyFrom, chain, hashBSC);
        return true;
    }
    function checkNextStage() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.currentStage == 6) {
            return;
        }
        if (
            ds.stages[ds.currentStage].raised >=
            ds.stages[ds.currentStage].totalRaise
        ) {
            ds.currentStage = ds.currentStage + 1;
        }
    }
    function buyTokenByEthAndStake(address refOf) external payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 ethAmount = msg.value;
        uint256 amount = getTokenAmountETH(ethAmount);
        require(amount > 0, "Amount is zero");
        require(ds.inSell, "Invalid time for buying");
        // if (ethAmount > msg.sender.balance) {
        //     revert();
        // }
        (ds._wallet).transfer(ethAmount);

        require(
            buyToken(
                msg.sender,
                ds.stake.getWallet(),
                amount,
                ethAmount,
                "ETH",
                "ETH",
                refOf,
                ""
            ),
            "Buy ds.token error"
        );
        require(
            ds.stake.stakeFromPresale(msg.sender, amount),
            "Stake ds.token error"
        );
    }
    function getWallet() public view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._wallet;
    }
    function buyTokenByUSDTAndStake(
        uint256 amountUSDT,
        address refOf
    ) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 amount = getTokenAmountUSDT(amountUSDT);
        require(amount > 0, "Amount is zero");
        require(ds.inSell, "Invalid time for buying");
        uint256 ourAllowance = ds.usdtToken.allowance(
            _msgSender(),
            address(this)
        );
        require(
            amountUSDT <= ourAllowance,
            "Make sure to add enough allowance"
        );

        ds.usdtToken.transferFrom(msg.sender, ds._wallet, amountUSDT);
        require(
            buyToken(
                msg.sender,
                ds.stake.getWallet(),
                amount,
                amountUSDT,
                "USDT",
                "ETH",
                refOf,
                ""
            ),
            "Buy ds.token error"
        );
        require(
            ds.stake.stakeFromPresale(msg.sender, amount),
            "Stake ds.token error"
        );
    }
    function getTokenAmountUSDT(
        uint256 amountUSDT
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 lastUSDTPriceByUSD = getLatestPriceUSDTPerUSD();
        return
            (amountUSDT * 10 ** 12 * lastUSDTPriceByUSD) /
            getPriceInUSD(ds.currentStage);
    }
    function getLatestPriceUSDTPerUSD() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (, int256 price, , , ) = ds.aggregatorUSDTInterface.latestRoundData();
        price = (price * (10 ** 10));
        return uint256(price);
    }
    function buyTokenByUSDT(uint256 amountUSDT, address refOf) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 amount = getTokenAmountUSDT(amountUSDT);
        require(amount > 0, "Amount is zero");
        require(ds.inSell, "Invalid time for buying");
        uint256 ourAllowance = ds.usdtToken.allowance(
            _msgSender(),
            address(this)
        );
        require(
            amountUSDT <= ourAllowance,
            "Make sure to add enough allowance"
        );

        ds.usdtToken.transferFrom(
            msg.sender,
            ds._wallet,
            (amountUSDT * 950) / 1000
        );
        buyToken(
            msg.sender,
            msg.sender,
            amount,
            amountUSDT,
            "USDT",
            "ETH",
            refOf,
            ""
        );
    }
    function stakeFromStakeContract(
        address _buyer,
        uint256 _amount
    ) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.stake.getAddress(),
            "Only call from stakecontract"
        );
        ds.buyers[_buyer] = ds.buyers[_buyer].sub(_amount);
        ds.buyers[ds.stake.getWallet()] = ds.buyers[ds.stake.getWallet()].add(
            _amount
        );
        emit Stake(_buyer, _amount);
        return true;
    }
    function getAddress() public view returns (address) {
        return address(this);
    }
    function buyTokenFromBSC(
        address buyer,
        uint256 amount,
        uint256 amountBSC,
        string memory buyFrom,
        address refOf,
        string memory hash
    ) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._brigdeBuyTokenFromBSC, "Only call by brigde");
        require(!ds.hashBuyBSC[hash], "This hash was processed");
        require(
            buyToken(
                buyer,
                buyer,
                amount,
                amountBSC,
                buyFrom,
                "BSC",
                refOf,
                hash
            ),
            "Buy ds.token error"
        );
        ds.hashBuyBSC[hash] = true;
    }
}
