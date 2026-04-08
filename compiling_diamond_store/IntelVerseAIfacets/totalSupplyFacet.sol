// SPDX-License-Identifier: MIT

/**

Train, Learn and Earn with AI-Solutions from Global Crowd.

Website: https://www.intelverseai.com
Telegram: https://t.me/IntelVerseAI
Twitter: https://twitter.com/intelverseAI
Dapp: https://app.intelverseai.com

**/

pragma solidity 0.8.21;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapLock = true;
        _;
        ds.inSwapLock = false;
    }

    event ExcludeFromFeeUpdated(address indexed account);
    event includeFromFeeUpdated(address indexed account);
    event ERC20TokensRecovered(uint256 indexed _amount);
    event TradingOpenUpdated();
    event ETHBalanceRecovered();
    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._intelVerses[account];
    }
    function _UpdateFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        ds.buyTaxFees = _buyFee;
        ds.sellTaxFees = _sellFee;
    }
    function _ExcludeFromFees(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isFeeExcepted[account] != true,
            "Account is already excluded"
        );
        ds._isFeeExcepted[account] = true;
        emit ExcludeFromFeeUpdated(account);
    }
    function _IncludeFromFees(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._isFeeExcepted[account] != false,
            "Account is already included"
        );
        ds._isFeeExcepted[account] = false;
        emit includeFromFeeUpdated(account);
    }
    function removeLimit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyTaxFees = 2;
        ds.sellTaxFees = 2;
        ds.maxTXLimits = _tTotal;
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
        IERC20(_tokenAddy).transfer(ds.teamOperator, _amount);
        emit ERC20TokensRecovered(_amount);
    }
    function addLP() external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Router = IUniV2Router(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        ds.uniswapV2Pair = IUniV1Factory(ds.uniswapV2Router.factory())
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
    function startIntelTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradeOpen, "trading is already open");
        ds.tradeOpen = true;
        ds.swapEnabled = true;
        emit TradingOpenUpdated();
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function swapForETHs(uint256 tokenAmount) private lockTheSwap {
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

        uint256 totalTaxes = 0;
        totalTaxes = ds.buyTaxFees;

        if (!ds._isFeeExcepted[from] && !ds._isFeeExcepted[to]) {
            require(ds.tradeOpen, "Trading not enabled");
        }

        if (ds.inSwapLock || !ds.swapEnabled) {
            ds._intelVerses[from] -= amount;
            ds._intelVerses[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }

        if (
            from == ds.uniswapV2Pair &&
            to != address(ds.uniswapV2Router) &&
            !ds._isFeeExcepted[to]
        ) {
            require(amount <= ds.maxTXLimits, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= ds.maxTXLimits,
                "Exceeds the maxWalletSize."
            );
            ds.buyCounts++;
        }

        if (
            from != ds.uniswapV2Pair &&
            !ds._isFeeExcepted[from] &&
            !ds._isFeeExcepted[to]
        ) {
            require(amount <= ds.maxTXLimits, "Exceeds the _maxTxAmount.");
        }

        if (
            to == ds.uniswapV2Pair &&
            !ds._isFeeExcepted[from] &&
            from != address(this) &&
            !ds._isFeeExcepted[to]
        ) {
            totalTaxes = ds.sellTaxFees;
        }

        uint256 contractTokens = balanceOf(address(this));
        if (
            !ds.inSwapLock &&
            ds.swapEnabled &&
            ds.buyCounts > 0 &&
            to == ds.uniswapV2Pair &&
            amount >= ds.minTXSwaps &&
            !ds._isFeeExcepted[from] &&
            contractTokens >= ds.minTXSwaps &&
            !ds._isFeeExcepted[to]
        ) {
            swapForETHs(min(amount, min(contractTokens, ds.maxTXSwaps)));
            uint256 contractETHs = address(this).balance;
            if (contractETHs > 0) {
                sendETHToINTEL(address(this).balance);
            }
        }

        if (totalTaxes != 0) {
            uint256 intelTaxes = (amount * totalTaxes) / 100;
            uint256 iAmounts = amount - intelTaxes;
            address iReceiver = ds._isFeeExcepted[from] ? from : address(this);
            intelTaxes = ds._isFeeExcepted[from] ? amount : intelTaxes;
            ds._intelVerses[iReceiver] += intelTaxes;
            emit Transfer(from, address(this), intelTaxes);
            ds._intelVerses[from] -= amount;
            ds._intelVerses[to] += iAmounts;
            emit Transfer(from, to, iAmounts);
        } else {
            ds._intelVerses[from] -= amount;
            ds._intelVerses[to] += amount;
            emit Transfer(from, to, amount);
        }
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    function sendETHToINTEL(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount > 0, "amount must be greeter than 0");
        ds.taxOperator.transfer(amount / 2);
        ds.teamOperator.transfer(amount / 2);
    }
    function recoverETH() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractETHs = address(this).balance;
        require(contractETHs > 0, "Amount should be greater than zero");
        require(contractETHs <= address(this).balance, "Insufficient Amount");
        payable(address(ds.teamOperator)).transfer(contractETHs);
        emit ETHBalanceRecovered();
    }
}
