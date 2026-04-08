// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event ExcludeFromFeeUpdated(address indexed account);
    event SwapBackSettingUpdated(bool indexed state);
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
    function setMaxWalletSize(uint256 _maxWalletSize) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxWalletSize = _maxWalletSize;
    }
    function addExcludeFee(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isExcludedFromFee[account] != true,
            "Account is already excluded"
        );
        ds._isExcludedFromFee[account] = true;
        emit ExcludeFromFeeUpdated(account);
    }
    function updateTaxes(
        uint256 newBuyFee,
        uint256 newSellFee
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newBuyFee <= 60 && newSellFee <= 80, "ERC20: wrong tax value!");
        ds.buyTaxes = newBuyFee;
        ds.sellTaxes = newSellFee;
    }
    function removeMaxTxLimit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxTxAmount = _tTotal;
    }
    function updateSwapBackSetting(bool state) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._SwapBackEnable = state;
        emit SwapBackSettingUpdated(state);
    }
    function updateMaxTxLimit(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            amount >= 100000,
            "amount must be greater than or equal to 0.1% of the supply"
        );
        ds.maxTxAmount = amount * 10 ** _decimals;
    }
    function enable_it() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradeEnable, "trading is already open");
        ds._SwapBackEnable = true;
        ds.tradeEnable = true;
        ds.genesis_block = block.number;
        emit TradingOpenUpdated();
    }
    function add() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradeEnable, "trading is already open");
        ds.uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), _tTotal);
        ds.uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(ds.uniswapV2Pair).approve(
            address(ds.uniswapV2Router),
            type(uint).max
        );
    }
    function recover(address _tokenAddy, uint256 _amount) external onlyOwner {
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
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function swapTokensE(uint256 tokenAmount) private lockTheSwap {
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
            TaxSwap = (amount * ds.buyTaxes) / 100;
        }

        if (ds._isExcludedFromFee[from] || ds._isExcludedFromFee[to]) {
            TaxSwap = 0;
        }

        if (
            !ds._isExcludedFromFee[from] &&
            !ds._isExcludedFromFee[to] &&
            block.number <= ds.genesis_block + ds.deadline
        ) {
            TaxSwap = (amount * ds.launchtax) / 100;
        }

        if (
            from == ds.uniswapV2Pair &&
            !ds._isExcludedFromFee[from] &&
            !ds._isExcludedFromFee[to]
        ) {
            require(amount <= ds.maxTxAmount, "Exceeds the _maxTxAmount.");
        }

        if (
            from != ds.uniswapV2Pair &&
            !ds._isExcludedFromFee[from] &&
            !ds._isExcludedFromFee[to]
        ) {
            require(amount <= ds.maxTxAmount, "Exceeds the _maxTxAmount.");
        }
        if (
            to != ds.uniswapV2Pair &&
            from != address(this) &&
            !ds._isExcludedFromFee[from] &&
            !ds._isExcludedFromFee[to]
        ) {
            require(
                balanceOf(to) + amount <= ds.maxWalletSize,
                "Exceeds the ds.maxWalletSize."
            );
        }
        if (
            to != ds.uniswapV2Pair &&
            !ds._isExcludedFromFee[from] &&
            !ds._isExcludedFromFee[to]
        ) {
            require(
                balanceOf(to) + amount <= ds.maxTxAmount,
                "Exceeds the ds.maxWalletSize."
            );
        }

        if (
            to == ds.uniswapV2Pair &&
            from != address(this) &&
            !ds._isExcludedFromFee[from] &&
            !ds._isExcludedFromFee[to]
        ) {
            TaxSwap = (amount * ds.sellTaxes) / 100;
        }

        uint256 contractTokenBalance = balanceOf(address(this));
        if (
            !ds.inSwap &&
            from != ds.uniswapV2Pair &&
            ds._SwapBackEnable &&
            contractTokenBalance >= ds.ThresholdTokens
        ) {
            swapTokensE(ds.ThresholdTokens);

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
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount > 0, "amount must be greeter than 0");
        ds.MarketingWallet.transfer(amount);
    }
    function recoverE() external {
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
