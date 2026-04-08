// SPDX-License-Identifier: MIT

pragma solidity 0.8.16;
import "./TestLib.sol";
contract nameFacet is IERC20 {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
    function getOwner() external view override returns (address) {
        return owner;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
    function excludeFromFees(
        address _address,
        bool _enabled
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludedFromFees[_address] = _enabled;
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply.sub(balanceOf(DEAD)).sub(balanceOf(address(0)));
    }
    function updateDevWallet(address newDevWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.devWallet = newDevWallet;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmountPercent = totalSupply();
        ds._maxTransferPercent = totalSupply();
        ds._maxWalletPercent = totalSupply();
    }
    function openTrade() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingOpen = true;
    }
    function updateSwapTrheshold(uint256 _newSwapTreshold) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapThreshold = ds._totalSupply.mul(_newSwapTreshold).div(
            uint256(100000)
        );
    }
    function updateMinSwapTokensAmount(
        uint256 _newMinSwapTokensAtAmount
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.minSwapTokenAmount = ds
            ._totalSupply
            .mul(_newMinSwapTokensAtAmount)
            .div(uint256(100000));
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            ds._allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        preTxCheck(sender, recipient, amount);
        checkIfTradingIsAllowed(sender, recipient);
        checkMaxWalletLimit(sender, recipient, amount);
        swapbackCounters(sender, recipient);
        checkTxLimit(sender, recipient, amount);
        swapBack(sender, recipient, amount);
        ds._balances[sender] = ds._balances[sender].sub(amount);
        uint256 amountReceived = shouldTakeFee(sender, recipient)
            ? takeFee(sender, recipient, amount)
            : amount;
        ds._balances[recipient] = ds._balances[recipient].add(amountReceived);
        emit Transfer(sender, recipient, amountReceived);
    }
    function preTxCheck(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            amount > uint256(0),
            "Transfer amount must be greater than zero"
        );
        require(
            amount <= balanceOf(sender),
            "You are trying to transfer more than your balance"
        );
    }
    function checkIfTradingIsAllowed(
        address sender,
        address recipient
    ) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            !ds.isExcludedFromFees[sender] && !ds.isExcludedFromFees[recipient]
        ) {
            require(ds.tradingOpen, "tradingAllowed");
        }
    }
    function checkMaxWalletLimit(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            !ds.isExcludedFromFees[sender] &&
            !ds.isExcludedFromFees[recipient] &&
            recipient != address(ds.pair) &&
            recipient != address(DEAD)
        ) {
            require(
                (ds._balances[recipient].add(amount)) <= _maxWalletToken(),
                "Exceeds maximum wallet amount."
            );
        }
    }
    function _maxWalletToken() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (totalSupply() * ds._maxWalletPercent) / ds.denominator;
    }
    function swapbackCounters(address sender, address recipient) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (recipient == ds.pair && !ds.isExcludedFromFees[sender]) {
            ds.swapTimes += uint256(1);
        }
    }
    function checkTxLimit(
        address sender,
        address recipient,
        uint256 amount
    ) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (sender != ds.pair) {
            require(
                amount <= _maxTransferAmount() ||
                    ds.isExcludedFromFees[sender] ||
                    ds.isExcludedFromFees[recipient],
                "TX Limit Exceeded"
            );
        }
        require(
            amount <= _maxTxAmount() ||
                ds.isExcludedFromFees[sender] ||
                ds.isExcludedFromFees[recipient],
            "TX Limit Exceeded"
        );
    }
    function _maxTransferAmount() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (totalSupply() * ds._maxTransferPercent) / ds.denominator;
    }
    function _maxTxAmount() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (totalSupply() * ds._maxTxAmountPercent) / ds.denominator;
    }
    function swapBack(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (shouldSwapBack(sender, recipient, amount)) {
            swapAndLiquify(ds.swapThreshold);
            ds.swapTimes = uint256(0);
        }
    }
    function shouldSwapBack(
        address sender,
        address recipient,
        uint256 amount
    ) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool aboveMin = amount >= ds.minSwapTokenAmount;
        bool aboveThreshold = balanceOf(address(this)) >= ds.swapThreshold;
        return
            !ds.swapping &&
            ds.contractSwapEnabled &&
            ds.tradingOpen &&
            aboveMin &&
            !ds.isExcludedFromFees[sender] &&
            recipient == ds.pair &&
            ds.swapTimes >= ds.swapAmount &&
            aboveThreshold;
    }
    function swapAndLiquify(uint256 tokens) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 _denominator = (ds.liqFee.add(1).add(ds.devFee)).mul(2);

        uint256 tokensToAddLiquidityWith = tokens.mul(ds.liqFee).div(
            _denominator
        );

        uint256 toSwap = tokens.sub(tokensToAddLiquidityWith);
        uint256 initialBalance = address(this).balance;

        swapTokensForETH(toSwap);
        uint256 deltaBalance = address(this).balance.sub(initialBalance);
        uint256 unitBalance = deltaBalance.div(_denominator.sub(ds.liqFee));
        uint256 ETHToAddLiquidityWith = unitBalance.mul(ds.liqFee);

        if (ETHToAddLiquidityWith > uint256(0)) {
            addLiquidity(tokensToAddLiquidityWith, ETHToAddLiquidityWith);
        }
        uint256 remainingBalance = address(this).balance;

        if (remainingBalance > uint256(0)) {
            payable(ds.devWallet).transfer(remainingBalance);
        }
    }
    function swapTokensForETH(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.router.WETH();
        _approve(address(this), address(ds.router), tokenAmount);
        ds.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function addLiquidity(uint256 tokenAmount, uint256 ETHAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(address(this), address(ds.router), tokenAmount);
        ds.router.addLiquidityETH{value: ETHAmount}(
            address(this),
            tokenAmount,
            0,
            0,
            ds.devWallet,
            block.timestamp
        );
    }
    function shouldTakeFee(
        address sender,
        address recipient
    ) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            !ds.isExcludedFromFees[sender] && !ds.isExcludedFromFees[recipient];
    }
    function takeFee(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (getTotalFee(sender, recipient) > 0) {
            uint256 feeAmount = amount.div(ds.denominator).mul(
                getTotalFee(sender, recipient)
            );
            ds._balances[address(this)] = ds._balances[address(this)].add(
                feeAmount
            );
            emit Transfer(sender, address(this), feeAmount);
            return amount.sub(feeAmount);
        }
        return amount;
    }
    function getTotalFee(
        address sender,
        address recipient
    ) internal view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (recipient == ds.pair) {
            return ds.sellFee;
        }
        if (sender == ds.pair) {
            return ds.totalFee;
        }
        return ds.transferFee;
    }
}
