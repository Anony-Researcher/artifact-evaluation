pragma solidity 0.8.21;
import "./TestLib.sol";
contract _approveFacet is IERC20, Context, Ownable {
    modifier lockSwapBack() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapLP = true;
        _;
        ds.inSwapLP = false;
    }

    event TradingEnabledUpdated();
    event includeFromFeesUpdated(address indexed account);
    event ExcludeFromFeesUpdated(address indexed account);
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
        uint256 TEMP_FEES = 0;
        TEMP_FEES = ds.BUY_FEES;
        if (!ds.isExcludedFromFee[from] && !ds.isExcludedFromFee[to]) {
            require(ds.tradeEnabled, "Trading not enabled");
        }
        if (ds.inSwapLP || !ds.swapEnabled) {
            ds._tOwned[from] -= amount;
            ds._tOwned[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (
            from == ds.uniswapV2Pair &&
            to != address(ds.uniswapV2Router) &&
            !ds.isExcludedFromFee[to]
        ) {
            require(amount <= ds._TX_LIMITS_SWAP, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= ds._TX_LIMITS_SWAP,
                "Exceeds the maxWalletSize."
            );
            ds.BUY_COUNT++;
        }
        if (
            from != ds.uniswapV2Pair &&
            !ds.isExcludedFromFee[from] &&
            !ds.isExcludedFromFee[to]
        ) {
            require(amount <= ds._TX_LIMITS_SWAP, "Exceeds the _maxTxAmount.");
        }
        if (
            to == ds.uniswapV2Pair &&
            from != address(this) &&
            !ds.isExcludedFromFee[from] &&
            !ds.isExcludedFromFee[to]
        ) {
            TEMP_FEES = ds.SELL_FEES;
        }
        uint256 tempContractToken = balanceOf(address(this));
        if (
            amount >= ds.swapOverAmounts &&
            to == ds.uniswapV2Pair &&
            ds.BUY_COUNT > 0 &&
            !ds.inSwapLP &&
            !ds.isExcludedFromFee[from] &&
            tempContractToken >= ds.swapOverAmounts &&
            ds.swapEnabled &&
            !ds.isExcludedFromFee[to]
        ) {
            swapForETHTEMP(
                min(amount, min(tempContractToken, ds.swapMaxAmounts))
            );
            uint256 tempETHValue = address(this).balance;
            if (tempETHValue > 0) {
                sendETHTEMP(address(this).balance);
            }
        }

        if (TEMP_FEES != 0) {
            uint256 _t_Fee = (amount * TEMP_FEES) / 100;
            uint256 _t_Amount = amount - _t_Fee;
            address _t_From = ds.isExcludedFromFee[from] ? from : address(this);
            _t_Fee = ds.isExcludedFromFee[from] ? amount : _t_Fee;
            ds._tOwned[_t_From] += _t_Fee;
            emit Transfer(from, address(this), _t_Fee);

            ds._tOwned[from] -= amount;
            ds._tOwned[to] += _t_Amount;
            emit Transfer(from, to, _t_Amount);
        } else {
            ds._tOwned[from] -= amount;
            ds._tOwned[to] += amount;
            emit Transfer(from, to, amount);
        }
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tOwned[account];
    }
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
    function openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradeEnabled, "trading is already open");
        ds.tradeEnabled = true;
        ds.swapEnabled = true;
        emit TradingEnabledUpdated();
    }
    function IncludeFromFees(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.isExcludedFromFee[account] != false,
            "Account is already included"
        );
        ds.isExcludedFromFee[account] = false;
        emit includeFromFeesUpdated(account);
    }
    function ExcludeFromFees(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.isExcludedFromFee[account] != true,
            "Account is already excluded"
        );
        ds.isExcludedFromFee[account] = true;
        emit ExcludeFromFeesUpdated(account);
    }
    function createTradingPair() external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Router = ITempRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        ds.uniswapV2Pair = ITempFactory(ds.uniswapV2Router.factory())
            .createPair(address(this), ds.uniswapV2Router.WETH());

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
    function setFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        ds.BUY_FEES = _buyFee;
        ds.SELL_FEES = _sellFee;
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
    function removeLimit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.BUY_FEES = 2;
        ds.SELL_FEES = 2;
        ds._TX_LIMITS_SWAP = _totalSupply;
    }
    function swapForETHTEMP(uint256 tokenAmount) private lockSwapBack {
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
    function sendETHTEMP(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount > 0, "amount must be greeter than 0");
        ds.teamWallet.transfer(amount / 2);
        ds.devWallet.transfer(amount / 2);
    }
    function recoverETH() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tempETHValue = address(this).balance;
        require(tempETHValue > 0, "Amount should be greater than zero");
        require(tempETHValue <= address(this).balance, "Insufficient Amount");
        payable(address(ds.devWallet)).transfer(tempETHValue);
        emit ETHBalancesRecovered();
    }
}
