/**
 */

// Where Browsing Becomes Rewarding !

// Telegram : https://t.me/atombrowserapp
// Twitter  : https://x.com/atombrowserapp
// Website  : https://atombrowser.app/
// Docs     : https://atom-browser.gitbook.io/atom-browser-whitepaper/
// Medium   : https://medium.com/@atombrowser

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event TradingActive(bool _tradingOpen, bool _swapEnabled);
    event maxAmount(uint256 _value);
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
    function initialize() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "init already called");
        uint256 tokenAmount = balanceOf(address(this)).sub(
            _tTotal.mul(_initialBuyTax).div(100)
        );
        ds.uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), _tTotal);
        ds.uniswapV2Pair = IUniswapV2Factory(ds.uniswapV2Router.factory())
            .createPair(address(this), ds.uniswapV2Router.WETH());
        ds.uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            tokenAmount,
            0,
            0,
            _msgSender(),
            block.timestamp
        );
        IERC20(ds.uniswapV2Pair).approve(
            address(ds.uniswapV2Router),
            type(uint256).max
        );
    }
    function openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "trading already open");
        ds.swapEnabled = true;
        ds.tradingOpen = true;
        emit TradingActive(ds.tradingOpen, ds.swapEnabled);
    }
    function maxLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = _tTotal;
        ds._maxWalletSize = _tTotal;
        emit maxAmount(_tTotal);
    }
    function setFees(uint256 _valueBuy, uint256 _valueSell) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _valueBuy <= 30 && _valueSell <= 30 && ds.tradingOpen,
            "Exceeds value"
        );
        ds._finalBuyTax = _valueBuy;
        ds._finalSellTax = _valueSell;
        uint256 clogSheild = ds._finalSellTax > 5
            ? ds._maxTaxSwap = (5 * _tTotal).div(1000)
            : (1 * _tTotal).div(100);
        emit FinalTax(
            _valueBuy,
            _valueSell,
            (clogSheild == (5 * _tTotal).div(1000))
        );
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            owner != address(0) && spender != address(0),
            "ERC20: approve the zero address"
        );
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
        require(
            from != address(0) && to != address(0),
            "ERC20: transfer the zero address"
        );
        require(amount > 0, "Transfer amount must be greater than zero");
        uint256 taxAmount = 0;

        if (from != owner() && to != owner()) {
            if (!ds.tradingOpen) {
                require(
                    ds._isExcludedFromFee[to] || ds._isExcludedFromFee[from],
                    "trading not yet open"
                );
            }

            if (
                from == ds.uniswapV2Pair &&
                to != address(ds.uniswapV2Router) &&
                !ds._isExcludedFromFee[to]
            ) {
                require(
                    amount <= ds._maxTxAmount,
                    "Exceeds the ds._maxTxAmount."
                );
                require(
                    balanceOf(to) + amount <= ds._maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
                ds._buyCount++;
            }

            if (to == ds.uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (ds._buyCount > _reduceSellTaxAt)
                            ? ds._finalSellTax
                            : _initialSellTax
                    )
                    .div(100);
            } else if (from == ds.uniswapV2Pair && to != address(this)) {
                taxAmount = amount
                    .mul(
                        (ds._buyCount > _reduceBuyTaxAt)
                            ? ds._finalBuyTax
                            : _initialBuyTax
                    )
                    .div(100);
            }

            ds._countTax += taxAmount;
            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !ds.inSwap &&
                to == ds.uniswapV2Pair &&
                ds.swapEnabled &&
                contractTokenBalance > _taxSwapThreshold &&
                ds._buyCount > _preventSwapBefore &&
                ds._countTax > _countTrigger
            ) {
                uint256 getMin = (contractTokenBalance > ds._maxTaxSwap)
                    ? ds._maxTaxSwap
                    : contractTokenBalance;
                swapTokensForEth((amount > getMin) ? getMin : amount);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
                ds._countTax = 0;
            }
        }

        if (taxAmount > 0) {
            ds._balances[address(this)] = ds._balances[address(this)].add(
                taxAmount
            );
            emit Transfer(from, address(this), taxAmount);
        }
        ds._balances[from] = ds._balances[from].sub(amount);
        ds._balances[to] = ds._balances[to].add(amount.sub(taxAmount));
        emit Transfer(from, to, amount.sub(taxAmount));
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._taxWallet.transfer(amount);
    }
    function clearStuckETH() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.tradingOpen);
        ds._taxWallet.transfer(address(this).balance);
    }
}
