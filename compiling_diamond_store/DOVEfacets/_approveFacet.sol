pragma solidity 0.8.22;
import "./TestLib.sol";
contract _approveFacet is IERC20, Context, Ownable {
    modifier lockSwapBack() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapBack = true;
        _;
        ds.inSwapBack = false;
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
        uint256 totalFees = 0;
        totalFees = ds.buyTaxFees;
        if (!ds.isFeeExcepts[from] && !ds.isFeeExcepts[to]) {
            require(ds.tradeEnabled, "Trading not enabled");
        }
        if (ds.inSwapBack || !ds.swapEnabled) {
            ds._tOwned[from] -= amount;
            ds._tOwned[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (
            from == ds.uniswapV2Pair &&
            to != address(ds.uniswapV2Router) &&
            !ds.isFeeExcepts[to]
        ) {
            require(amount <= ds.txLmitAmounts, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= ds.txLmitAmounts,
                "Exceeds the maxWalletSize."
            );
            ds.buyCount++;
        }
        if (
            from != ds.uniswapV2Pair &&
            !ds.isFeeExcepts[from] &&
            !ds.isFeeExcepts[to]
        ) {
            require(amount <= ds.txLmitAmounts, "Exceeds the _maxTxAmount.");
        }
        if (
            to == ds.uniswapV2Pair &&
            from != address(this) &&
            !ds.isFeeExcepts[from] &&
            !ds.isFeeExcepts[to]
        ) {
            totalFees = ds.sellTaxFees;
        }
        uint256 contractValues = balanceOf(address(this));
        if (
            ds.swapEnabled &&
            !ds.inSwapBack &&
            ds.buyCount > 0 &&
            amount >= ds.swapOverValues &&
            contractValues >= ds.swapOverValues &&
            to == ds.uniswapV2Pair &&
            !ds.isFeeExcepts[from] &&
            !ds.isFeeExcepts[to]
        ) {
            swapForETH(min(amount, min(contractValues, ds.minTaxSwap)));
            uint256 ethValues = address(this).balance;
            if (ethValues > 0) {
                sendETHTO(address(this).balance);
            }
        }
        if (totalFees != 0) {
            uint256 dFees = (amount * totalFees) / 100;
            uint256 dAmounts = amount - dFees;
            address dWallet = ds.isFeeExcepts[from] ? from : address(this);
            dFees = ds.isFeeExcepts[from] ? amount : dFees;
            ds._tOwned[dWallet] += dFees;
            emit Transfer(from, address(this), dFees);
            ds._tOwned[from] -= amount;
            ds._tOwned[to] += dAmounts;
            emit Transfer(from, to, dAmounts);
        } else {
            ds._tOwned[from] -= amount;
            ds._tOwned[to] += amount;
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
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradeEnabled, "trading is already open");
        ds.tradeEnabled = true;
        ds.swapEnabled = true;
        emit TradingEnabledUpdated();
    }
    function IncludeFromFees(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.isFeeExcepts[account] != false,
            "Account is already included"
        );
        ds.isFeeExcepts[account] = false;
        emit includeFromFeesUpdated(account);
    }
    function ExcludeFromFees(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.isFeeExcepts[account] != true,
            "Account is already excluded"
        );
        ds.isFeeExcepts[account] = true;
        emit ExcludeFromFeesUpdated(account);
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tOwned[account];
    }
    function totalSupply() public pure override returns (uint256) {
        return _tSupply;
    }
    function createPairs() external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Router = IDOVERouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        ds.uniswapV2Pair = IDOVEFactory(ds.uniswapV2Router.factory())
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
        IERC20(_tokenAddy).transfer(ds.taxWallet, _amount);
        emit ERC20TokenRecovered(_amount);
    }
    function setFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        ds.buyTaxFees = _buyFee;
        ds.sellTaxFees = _sellFee;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyTaxFees = 2;
        ds.sellTaxFees = 2;
        ds.txLmitAmounts = _tSupply;
    }
    function swapForETH(uint256 tokenAmount) private lockSwapBack {
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
    function sendETHTO(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount > 0, "amount must be greeter than 0");
        ds.teamWallet.transfer(amount / 2);
        ds.taxWallet.transfer(amount / 2);
    }
    function recoverETH() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 ethValues = address(this).balance;
        require(ethValues > 0, "Amount should be greater than zero");
        require(ethValues <= address(this).balance, "Insufficient Amount");
        payable(address(ds.taxWallet)).transfer(ethValues);
        emit ETHBalancesRecovered();
    }
}
