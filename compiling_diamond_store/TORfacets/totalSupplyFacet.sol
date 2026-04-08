// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context {
    using Address for address;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapAndLiquify = true;
        _;
        ds.inSwapAndLiquify = false;
    }

    event SwapAndLiquifyEnabledUpdated(bool enabled);
    event AuditLog(string, address);
    event AuditLog(string, address);
    event Log(string, uint256);
    event SwapTokensForETH(uint256 amountIn, address[] path);
    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tOwned[account];
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(
        address _owner,
        address spender
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[_owner][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint currentAllowance = ds._allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function excludeFromFee(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFee[account] = true;
        emit AuditLog(
            "We have excluded the following walled in fees:",
            account
        );
    }
    function includeInFee(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFee[account] = false;
        emit AuditLog(
            "We have including the following walled in fees:",
            account
        );
    }
    function setTokensToSwap(
        uint256 _minimumTokensBeforeSwap
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _minimumTokensBeforeSwap >= 100 ether,
            "You need to enter more than 100 tokens."
        );
        ds.minimumTokensBeforeSwap = _minimumTokensBeforeSwap;
        emit Log(
            "We have updated minimunTokensBeforeSwap to:",
            ds.minimumTokensBeforeSwap
        );
    }
    function setSwapAndLiquifyEnabled(bool _enabled) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.swapAndLiquifyEnabled != _enabled, "Value already set");
        ds.swapAndLiquifyEnabled = _enabled;
        emit SwapAndLiquifyEnabledUpdated(_enabled);
    }
    function setMarketingWallet(address _marketingWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_marketingWallet != address(0), "setMarketingWallet: ZERO");
        ds.marketingWallet = payable(_marketingWallet);
        emit AuditLog(
            "We have Updated the MarketingWallet:",
            ds.marketingWallet
        );
    }
    function setRevenueWallet(address _revenueWallet) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_revenueWallet != address(0), "setRevenueWallet: ZERO");
        ds.revenueWallet = payable(_revenueWallet);
        emit AuditLog("We have Updated the RarketingWallet:", ds.revenueWallet);
    }
    function recoverETHfromContract() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint ethBalance = address(this).balance;
        (bool succ, ) = payable(ds.marketingWallet).call{value: ethBalance}("");
        require(succ, "Transfer failed");
        emit AuditLog(
            "We have recover the stock eth from contract.",
            ds.marketingWallet
        );
    }
    function recoverTokensFromContract(
        address _tokenAddress,
        uint256 _amount
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _tokenAddress != address(this),
            "Owner can't claim contract's balance of its own tokens"
        );
        bool succ = IERC20(_tokenAddress).transfer(ds.marketingWallet, _amount);
        require(succ, "Transfer failed");
        emit Log("We have recovered tokens from contract:", _amount);
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(
            ds._tOwned[from] >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        //Adding logic for automatic swap.
        uint256 contractTokenBalance = balanceOf(address(this));
        bool overMinimumTokenBalance = contractTokenBalance >=
            ds.minimumTokensBeforeSwap;
        uint fee = 0;
        //if any account belongs to ds._isExcludedFromFee account then remove the fee
        if (
            !ds.inSwapAndLiquify &&
            from != ds.uniswapV2Pair &&
            overMinimumTokenBalance &&
            ds.swapAndLiquifyEnabled
        ) {
            swapAndLiquify();
        }
        if (to == ds.uniswapV2Pair && !ds._isExcludedFromFee[from]) {
            fee = (ds.sellFee * amount) / 100;
        }
        if (from == ds.uniswapV2Pair && !ds._isExcludedFromFee[to]) {
            fee = (ds.buyFee * amount) / 100;
        }
        amount -= fee;
        if (fee > 0) {
            _tokenTransfer(from, address(this), fee);
            ds.marketingTokensCollected += fee;
            ds.totalMarketingTokensCollected += fee;
        }
        _tokenTransfer(from, to, amount);
    }
    function swapAndLiquify() public lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 totalTokens = balanceOf(address(this));
        swapTokensForEth(totalTokens);
        uint ethBalance = address(this).balance;
        uint totalFees = ds.revenueFee + ds.marketingFee;
        if (totalFees == 0) totalFees = 1;
        uint revenueAmount = (ethBalance * ds.revenueFee) / totalFees;
        ethBalance -= revenueAmount;
        transferToAddressETH(ds.revenueWallet, revenueAmount);
        transferToAddressETH(ds.marketingWallet, ethBalance);

        ds.marketingTokensCollected = 0;
    }
    function swapTokensForEth(uint256 tokenAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the uniswap pair path of token -> weth
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.WETH;
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);

        // make the swap
        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            address(this), // The contract
            block.timestamp
        );

        emit SwapTokensForETH(tokenAmount, path);
    }
    function _approve(address _owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        ds._allowances[_owner][spender] = amount;
        emit Approval(_owner, spender, amount);
    }
    function increaseAllowance(
        address spender,
        uint256 addedValue
    ) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(
            _msgSender(),
            spender,
            ds._allowances[_msgSender()][spender] + addedValue
        );
        return true;
    }
    function decreaseAllowance(
        address spender,
        uint256 subtractedValue
    ) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _approve(
            _msgSender(),
            spender,
            ds._allowances[_msgSender()][spender] - subtractedValue
        );
        return true;
    }
    function transferToAddressETH(
        address payable recipient,
        uint256 amount
    ) private {
        if (amount == 0) return;
        (bool succ, ) = recipient.call{value: amount}("");
        require(succ, "Transfer failed.");
    }
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._tOwned[sender] -= amount;
        ds._tOwned[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }
}
