pragma solidity ^0.8.3;
import "./TestLib.sol";
contract _beforeTokenTransferFacet is DeHubTokenV4WithVersion, Uniswap {
    modifier lockTheProcess() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inTriggerProcess = true;
        _;
        ds.inTriggerProcess = false;
    }

    event SoldTax(uint256 tokensSold, uint256 usdtReceived);
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        super._beforeTokenTransfer(from, to, amount);

        TransactionType txType = _getTransactionType(from, to);

        if (!ds.inTriggerProcess && txType == TransactionType.REGULAR) {
            _triggerSellTax();
        }
    }
    function _takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.inTriggerProcess) {
            return 0;
        }
        return super._takeFee(sender, recipient, amount);
    }
    function _triggerSellTax() internal virtual {
        uint256 contractTokenBalance = balanceOf(address(this));
        if (_canSellTax(contractTokenBalance)) {
            _sellTax(contractTokenBalance);
        }
    }
    function _canSellTax(
        uint256 contractTokenBalance
    ) internal view virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return contractTokenBalance >= ds.minTaxForSell && ds.minTaxForSell > 0;
    }
    function _sellTax(uint256 tokenAmount) internal virtual lockTheProcess {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tokensSold;
        uint256 usdtReceived;

        if (taxTo != address(0) && tokenAmount > 0) {
            _approve(address(this), address(uniswapV2Router), tokenAmount);

            address[] memory path = new address[](2);
            path[0] = address(this);
            path[1] = ds.USDT;

            uint256 initialBalance = IERC20(ds.USDT).balanceOf(taxTo);
            swapTokensByPath(tokenAmount, 1, path, taxTo);
            usdtReceived = IERC20(ds.USDT).balanceOf(taxTo) - initialBalance;
            if (usdtReceived > 0) {
                tokensSold = tokenAmount;
            }
        }
        emit SoldTax(tokensSold, usdtReceived);
    }
}
