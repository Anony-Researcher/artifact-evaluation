// telegram: https://t.me/flepeth
// website: https://flepe.io
// X Handle: https://x.com/flepeth

// Floki vs Pepe
// $FLEPE > $FLOKI $PEPE

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event SwapBackSettingUpdated(bool indexed state);
    event ExcludeFromFeeUpdated(address indexed account);
    event includeFromFeeUpdated(address indexed account);
    event TradingOpenUpdated();
    event ERC20TokensRecovered(uint256 indexed _amount);
    event ETHBalanceRecovered();
    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
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
        uint256 currentAllowance = ds._allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        _transfer(sender, recipient, amount);
        _approve(sender, _msgSender(), currentAllowance - amount);
        return true;
    }
    function removeMaxTxLimit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxTxAmount = _tTotal;
    }
    function updateFinalFee() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isFinalFeeDone = true;
    }
    function updateSwapBackSetting(bool state) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._SwapBackEnable = state;
        emit SwapBackSettingUpdated(state);
    }
    function whitelistWallet(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isExcludedFromFee[account] != true,
            "Account is already excluded"
        );
        ds._isExcludedFromFee[account] = true;
        emit ExcludeFromFeeUpdated(account);
    }
    function removeWhitelist(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isExcludedFromFee[account] != false,
            "Account is already included"
        );
        ds._isExcludedFromFee[account] = false;
        emit includeFromFeeUpdated(account);
    }
    function manualSwap() external onlyOwner {
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradeEnable, "trading is already open");
        ds._SwapBackEnable = true;
        ds.tradeEnable = true;
        emit TradingOpenUpdated();
    }
    function recoverERC20(
        address _tokenAddy,
        uint256 _amount
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _tokenAddy != address(this),
            "Owner can't claim contract's balance of its own tokens"
        );
        require(_amount > 0, "Amount should be greater than zero");
        require(
            _amount <= IERC20(_tokenAddy).balanceOf(address(this)),
            "Insufficient Amount"
        );
        IERC20(_tokenAddy).transfer(ds.MarketingWallet, _amount);
        emit ERC20TokensRecovered(_amount);
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(tokenAmount > 0, "amount must be greeter than 0");
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.uniswapV2Router.WETH();
        _approve(address(this), address(ds.uniswapV2Router), tokenAmount);
        ds.uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            address(this),
            block.timestamp
        );
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 TaxSwap = 0;

        if (!ds._isExcludedFromFee[from] && !ds._isExcludedFromFee[to]) {
            require(ds.tradeEnable, "Trading not enabled");
            TaxSwap =
                (amount *
                    ((ds._isFinalFeeDone) ? ds.buyTaxes : ds._launchBuyTax)) /
                (100);
        }

        if (ds._isExcludedFromFee[from] || ds._isExcludedFromFee[to]) {
            TaxSwap = 0;
        }

        if (
            from == ds.uniswapV2Pair &&
            to != address(ds.uniswapV2Router) &&
            !ds._isExcludedFromFee[to]
        ) {
            require(amount <= ds.maxTxAmount, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= ds.maxTxAmount,
                "Exceeds the maxWalletSize."
            );
            ds._Buys_In++;
        }

        if (
            from != ds.uniswapV2Pair &&
            !ds._isExcludedFromFee[from] &&
            !ds._isExcludedFromFee[to]
        ) {
            require(amount <= ds.maxTxAmount, "Exceeds the _maxTxAmount.");
        }

        if (
            to == ds.uniswapV2Pair &&
            from != address(this) &&
            !ds._isExcludedFromFee[from] &&
            !ds._isExcludedFromFee[to]
        ) {
            TaxSwap =
                (amount *
                    ((ds._isFinalFeeDone) ? ds.sellTaxes : ds._launchSellTax)) /
                (100);
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if (
            !ds.inSwap &&
            from != ds.uniswapV2Pair &&
            ds._SwapBackEnable &&
            contractTokenBalance > ds.SwapTokens &&
            ds._Buys_In > 1
        ) {
            swapTokensForEth(
                min(amount, min(contractTokenBalance, ds.maxSwapTokens))
            );
            uint256 contractETHBalance = address(this).balance;
            if (contractETHBalance > 0) {
                sendETHToFee(address(this).balance);
            }
        }
        ds._balances[from] = ds._balances[from] - amount;
        ds._balances[to] = ds._balances[to] + (amount - (TaxSwap));
        emit Transfer(from, to, amount - (TaxSwap));
        if (TaxSwap > 0) {
            ds._balances[address(this)] =
                ds._balances[address(this)] +
                (TaxSwap);
            emit Transfer(from, address(this), TaxSwap);
        }
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount > 0, "amount must be greeter than 0");
        ds.MarketingWallet.transfer(amount);
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function recoverETH() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractETHBalance = address(this).balance;
        require(contractETHBalance > 0, "Amount should be greater than zero");
        require(
            contractETHBalance <= address(this).balance,
            "Insufficient Amount"
        );
        payable(address(ds.MarketingWallet)).transfer(contractETHBalance);
        emit ETHBalanceRecovered();
    }
}
