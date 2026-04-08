/**
 
*/

/**
 
*/

pragma solidity 0.8.20;
import "./TestLib.sol";
contract _transferFacet is ERC20, Ownable {
    event SetExemptFromFees(address _address, bool _isExempt);
    event SetExemptFromLimits(address _address, bool _isExempt);
    event UpdatedMaxTransaction(uint256 newMax);
    event UpdatedMaxWallet(uint256 newMax);
    event UpdatedBuyTax(uint256 newAmt);
    event UpdatedSellTax(uint256 newAmt);
    event RemovedLimits();
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Check if the addresses are blacklisted
        require(!ds.isBlacklisted[from], "Sender is blacklisted");
        require(!ds.isBlacklisted[to], "Recipient is blacklisted");

        if (ds.exemptFromFees[from] || ds.exemptFromFees[to] || ds.swapping) {
            super._transfer(from, to, amount);
            return;
        }

        require(ds.tradingActive, "Trading not active");

        if (ds.limitsInEffect) {
            checkLimits(from, to, amount);
        }

        amount -= handleTax(from, to, amount);

        super._transfer(from, to, amount);
    }
    function addToBlacklist(address _address) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_address != address(0), "Zero Address");
        ds.isBlacklisted[_address] = true;
    }
    function removeFromBlacklist(address _address) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_address != address(0), "Zero Address");
        ds.isBlacklisted[_address] = false;
    }
    function setExemptFromFees(
        address _address,
        bool _isExempt
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_address != address(0), "Zero Address");
        ds.exemptFromFees[_address] = _isExempt;
        emit SetExemptFromFees(_address, _isExempt);
    }
    function setExemptFromLimits(
        address _address,
        bool _isExempt
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_address != address(0), "Zero Address");
        if (!_isExempt) {
            require(_address != ds.lpPair, "Pair");
        }
        ds.exemptFromLimits[_address] = _isExempt;
        emit SetExemptFromLimits(_address, _isExempt);
    }
    function updateMaxTransaction(uint256 newNumInTokens) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNumInTokens >= ((totalSupply() * 5) / 1000) / (10 ** decimals()),
            "Too low"
        );
        ds.maxTransaction = newNumInTokens * (10 ** decimals());
        emit UpdatedMaxTransaction(ds.maxTransaction);
    }
    function updateMaxWallet(uint256 newNumInTokens) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newNumInTokens >= ((totalSupply() * 1) / 100) / (10 ** decimals()),
            "Too low"
        );
        ds.maxWallet = newNumInTokens * (10 ** decimals());
        emit UpdatedMaxWallet(ds.maxWallet);
    }
    function updateTaxes(uint256 _buyTax, uint256 _sellTax) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyTax = _buyTax;
        emit UpdatedBuyTax(ds.buyTax);
        ds.sellTax = _sellTax;
        emit UpdatedSellTax(ds.sellTax);
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingActive, "Trading active");
        ds.tradingActive = true;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;
        ds.transferDelayEnabled = false;
        ds.maxTransaction = totalSupply();
        ds.maxWallet = totalSupply();
        emit RemovedLimits();
    }
    function disableTransferDelay() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.transferDelayEnabled = false;
    }
    function updateOperationsAddress(address _address) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_address != address(0), "zero address");
        ds.operationsAddress = _address;
    }
    function checkLimits(address from, address to, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.transferDelayEnabled) {
            if (to != address(ds.dexRouter) && !ds.isAMMPair[to]) {
                require(
                    ds._holderLastTransferBlock[tx.origin] < block.number,
                    "Transfer Delay enabled."
                );
                ds._holderLastTransferBlock[tx.origin] = block.number;
            }
        }

        // buy
        if (ds.isAMMPair[from] && !ds.exemptFromLimits[to]) {
            require(amount <= ds.maxTransaction, "Max tx exceeded.");
            require(
                amount + balanceOf(to) <= ds.maxWallet,
                "Max wallet exceeded"
            );
        }
        // sell
        else if (ds.isAMMPair[to] && !ds.exemptFromLimits[from]) {
            require(amount <= ds.maxTransaction, "Max tx exceeded.");
        } else if (!ds.exemptFromLimits[to]) {
            require(
                amount + balanceOf(to) <= ds.maxWallet,
                "Max wallet exceeded"
            );
        }
    }
    function handleTax(
        address from,
        address to,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            balanceOf(address(this)) >= ds.swapTokensAtAmt &&
            !ds.swapping &&
            !ds.isAMMPair[from]
        ) {
            ds.swapping = true;
            swapBack();
            ds.swapping = false;
        }

        uint256 tax = 0;

        // on sell
        if (ds.isAMMPair[to] && ds.sellTax > 0) {
            tax = (amount * ds.sellTax) / FEE_DIVISOR;
        }
        // on buy
        else if (ds.isAMMPair[from] && ds.buyTax > 0) {
            tax = (amount * ds.buyTax) / FEE_DIVISOR;
        }

        if (tax > 0) {
            super._transfer(from, address(this), tax);
        }

        return tax;
    }
    function swapBack() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractBalance = balanceOf(address(this));

        if (contractBalance == 0) {
            return;
        }

        if (contractBalance > ds.swapTokensAtAmt * 40) {
            contractBalance = ds.swapTokensAtAmt * 40;
        }

        swapTokensForETH(contractBalance);

        if (address(this).balance > 0) {
            bool success;
            (success, ) = ds.operationsAddress.call{
                value: address(this).balance
            }("");
        }
    }
    function swapTokensForETH(uint256 tokenAmt) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.dexRouter.WETH();

        ds.dexRouter.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmt,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
}
