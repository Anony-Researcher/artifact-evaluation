// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract setBurnFeeFacet {
    function setBurnFee(uint256 burnFee_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._burnFee = burnFee_;
    }
    function setMarketingFee(uint256 marketingFee_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._marketingFee = marketingFee_;
    }
    function setDeveloperFee(uint256 developerFee_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._developerFee = developerFee_;
    }
    function setCharityFee(uint256 charityFee_) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._charityFee = charityFee_;
    }
    function setMarketingAddress(address _marketingAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.marketingAddress = _marketingAddress;
    }
    function setDeveloperAddress(address _developerAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.developerAddress = _developerAddress;
    }
    function setCharityAddress(address _charityAddress) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.charityAddress = _charityAddress;
    }
    function excludeFromFee(address account) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFee[account] = true;
    }
    function includeInFee(address account) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFee[account] = false;
    }
    function setReflectionFee(uint256 newReflectionFee) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._reflectionFee = newReflectionFee;
    }
    function excludeAccountFromReward(address account) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds._isExcluded[account], "Account is already excluded");
        if (ds._rOwned[account] > 0) {
            ds._tOwned[account] = tokenFromReflection(ds._rOwned[account]);
        }
        ds._isExcluded[account] = true;
        ds._excluded.push(account);
    }
    function includeAccountinReward(address account) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds._isExcluded[account], "Account is already included");
        for (uint256 i = 0; i < ds._excluded.length; i++) {
            if (ds._excluded[i] == account) {
                ds._excluded[i] = ds._excluded[ds._excluded.length - 1];
                ds._tOwned[account] = 0;
                ds._isExcluded[account] = false;
                ds._excluded.pop();
                break;
            }
        }
    }
    function tokenFromReflection(
        uint256 rAmount
    ) private view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            rAmount <= ds._rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }
    function balanceOf(
        address sender
    ) public view virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._isExcluded[sender]) {
            return ds._tOwned[sender];
        }
        return tokenFromReflection(ds._rOwned[sender]);
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        uint256 senderBalance = balanceOf(sender);
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        _beforeTokenTransfer(sender, recipient, amount);

        bool takeFee = true;

        if (ds._isExcludedFromFee[sender] || ds._isExcludedFromFee[recipient]) {
            takeFee = false;
        }

        _tokenTransfer(sender, recipient, amount, takeFee);
    }
    function _tokenTransfer(
        address from,
        address to,
        uint256 value,
        bool takeFee
    ) private {
        if (!takeFee) {
            removeAllFee();
        }

        _transferStandard(from, to, value);

        if (!takeFee) {
            restoreAllFee();
        }
    }
    function removeAllFee() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            ds._reflectionFee == 0 &&
            ds._burnFee == 0 &&
            ds._marketingFee == 0 &&
            ds._developerFee == 0 &&
            ds._charityFee == 0
        ) return;

        ds._previousReflectionFee = ds._reflectionFee;
        ds._previousBurnFee = ds._burnFee;
        ds._previousMarketingFee = ds._marketingFee;
        ds._previousDeveloperFee = ds._developerFee;
        ds._previousCharityFee = ds._charityFee;

        ds._reflectionFee = 0;
        ds._burnFee = 0;
        ds._marketingFee = 0;
        ds._developerFee = 0;
        ds._charityFee = 0;
    }
    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        (
            uint256 rAmount,
            uint256 rTransferAmount,
            uint256 tTransferAmount,
            uint256 currentRate
        ) = _getTransferValues(tAmount);

        ds._rOwned[sender] = ds._rOwned[sender] - rAmount;
        ds._rOwned[recipient] = ds._rOwned[recipient] + rTransferAmount;

        if (ds._isExcluded[sender] && !ds._isExcluded[recipient]) {
            ds._tOwned[sender] = ds._tOwned[sender] - tAmount;
        } else if (!ds._isExcluded[sender] && ds._isExcluded[recipient]) {
            ds._tOwned[recipient] = ds._tOwned[recipient] + tTransferAmount;
        } else if (ds._isExcluded[sender] && ds._isExcluded[recipient]) {
            ds._tOwned[sender] = ds._tOwned[sender] - tAmount;
            ds._tOwned[recipient] = ds._tOwned[recipient] + tTransferAmount;
        }

        _reflectFee(tAmount, currentRate);
        burnFeeTransfer(sender, tAmount, currentRate);
        feeTransfer(
            sender,
            tAmount,
            currentRate,
            ds._marketingFee,
            ds.marketingAddress
        );
        feeTransfer(
            sender,
            tAmount,
            currentRate,
            ds._developerFee,
            ds.developerAddress
        );
        feeTransfer(
            sender,
            tAmount,
            currentRate,
            ds._charityFee,
            ds.charityAddress
        );

        emit Transfer(sender, recipient, tTransferAmount);
    }
    function _getTransferValues(
        uint256 tAmount
    ) private view returns (uint256, uint256, uint256, uint256) {
        uint256 taxValue = _getCompleteTaxValue(tAmount);
        uint256 tTransferAmount = tAmount - taxValue;
        uint256 currentRate = _getRate();
        uint256 rTransferAmount = tTransferAmount * currentRate;
        uint256 rAmount = tAmount * currentRate;
        return (rAmount, rTransferAmount, tTransferAmount, currentRate);
    }
    function reflect(uint256 tAmount) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address sender = _msgSender();
        require(
            !ds._isExcluded[sender],
            "Excluded addresses cannot call this function"
        );
        (uint256 rAmount, , , ) = _getTransferValues(tAmount);
        ds._rOwned[sender] = ds._rOwned[sender] - rAmount;
        ds._rTotal = ds._rTotal - rAmount;
        ds._tFeeTotal = ds._tFeeTotal + tAmount;
    }
    function reflectionFromToken(
        uint256 tAmount,
        bool deductTransferFee
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(tAmount <= ds._tTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            (uint256 rAmount, , , ) = _getTransferValues(tAmount);
            return rAmount;
        } else {
            (, uint256 rTransferAmount, , ) = _getTransferValues(tAmount);
            return rTransferAmount;
        }
    }
    function _getCompleteTaxValue(
        uint256 tAmount
    ) private view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 allTaxes = ds._reflectionFee +
            ds._burnFee +
            ds._marketingFee +
            ds._developerFee +
            ds._charityFee;
        uint256 taxValue = (tAmount * allTaxes) / 100;
        return taxValue;
    }
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply / tSupply;
    }
    function _getCurrentSupply() private view returns (uint256, uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 rSupply = ds._rTotal;
        uint256 tSupply = ds._tTotal;

        for (uint256 i = 0; i < ds._excluded.length; i++) {
            if (
                ds._rOwned[ds._excluded[i]] > rSupply ||
                ds._tOwned[ds._excluded[i]] > tSupply
            ) {
                return (ds._rTotal, ds._tTotal);
            }
            rSupply = rSupply - ds._rOwned[ds._excluded[i]];
            tSupply = tSupply - ds._tOwned[ds._excluded[i]];
        }

        if (rSupply < ds._rTotal / ds._tTotal) {
            return (ds._rTotal, ds._tTotal);
        }

        return (rSupply, tSupply);
    }
    function _burn(address account, uint256 amount) internal virtual override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(account != address(0), "ERC20: burn from the zero address");
        uint256 accountBalance = balanceOf(account);
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 currentRate = _getRate();
        uint256 rAmount = amount * currentRate;

        if (ds._isExcluded[account]) {
            ds._tOwned[account] = ds._tOwned[account] - amount;
        }

        ds._rOwned[account] = ds._rOwned[account] - rAmount;

        ds._tTotal = ds._tTotal - amount;
        ds._rTotal = ds._rTotal - rAmount;
        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }
    function _reflectFee(uint256 tAmount, uint256 currentRate) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tFee = (tAmount * ds._reflectionFee) / 100;
        uint256 rFee = tFee * currentRate;

        ds._rTotal = ds._rTotal - rFee;
        ds._tFeeTotal = ds._tFeeTotal + tFee;
    }
    function burnFeeTransfer(
        address sender,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tBurnFee = (tAmount * ds._burnFee) / 100;
        if (tBurnFee > 0) {
            uint256 rBurnFee = tBurnFee * currentRate;
            ds._tTotal = ds._tTotal - tBurnFee;
            ds._rTotal = ds._rTotal - rBurnFee;
            emit Transfer(sender, address(0), tBurnFee);
        }
    }
    function feeTransfer(
        address sender,
        uint256 tAmount,
        uint256 currentRate,
        uint256 fee,
        address receiver
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tFee = (tAmount * fee) / 100;
        if (tFee > 0) {
            uint256 rFee = tFee * currentRate;
            ds._rOwned[receiver] = ds._rOwned[receiver] + rFee;
            emit Transfer(sender, receiver, tFee);
        }
    }
    function restoreAllFee() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._reflectionFee = ds._previousReflectionFee;
        ds._burnFee = ds._previousBurnFee;
        ds._marketingFee = ds._previousMarketingFee;
        ds._developerFee = ds._previousDeveloperFee;
        ds._charityFee = ds._previousCharityFee;
    }
}
