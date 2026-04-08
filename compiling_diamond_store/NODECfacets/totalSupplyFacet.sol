/*

Node Chain is a next-generation, Ethereum-compatible blockchain designed to offer low, 
constant gas fees and high throughput, 
ensuring efficiency and scalability for a wide range of applications.

TELEGRAM : https://t.me/NodeChainNet
TWITTER : https://twitter.com/NodeChainNet
WEBSITE : https://nodec.org

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.21;
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
    event FinalTax(uint256 _valueBuy, uint256 _valueSell);
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
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
    function CreatePair() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "init already called");
        uint256 tokenAmount = balanceOf(address(this)).sub(
            _totalSupply.mul(_initialBuyTax).div(100)
        );
        ds.uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), _totalSupply);
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
            type(uint).max
        );
    }
    function openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "trading already open");
        ds.swapEnabled = true;
        ds.tradingOpen = true;
        emit TradingActive(ds.tradingOpen, ds.swapEnabled);
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = _totalSupply;
        ds._maxWalletSize = _totalSupply;
        emit maxAmount(_totalSupply);
    }
    function setFinalTax(
        uint256 _valueBuy,
        uint256 _valueSell
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _valueBuy <= 30 && _valueSell <= 30 && ds.tradingOpen,
            "Exceeds value"
        );
        ds._finalBuyTax = _valueBuy;
        ds._finalSellTax = _valueSell;
        emit FinalTax(_valueBuy, _valueSell);
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
                taxAmount =
                    amount.mul(
                        (ds._buyCount > _reduceSellTaxAt)
                            ? ds._finalSellTax
                            : _initialSellTax
                    ) /
                    100;
            } else if (from == ds.uniswapV2Pair && to != address(this)) {
                taxAmount =
                    amount.mul(
                        (ds._buyCount > _reduceBuyTaxAt)
                            ? ds._finalBuyTax
                            : _initialBuyTax
                    ) /
                    100;
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
                uint256 getMinValue = (contractTokenBalance > _maxTaxSwap)
                    ? _maxTaxSwap
                    : contractTokenBalance;
                swapTokensForEth((amount > getMinValue) ? getMinValue : amount);
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(contractETHBalance);
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
        uint256 tax = (ds._buyCount > _reduceBuyTaxAt)
            ? ds._finalBuyTax
            : _initialBuyTax;
        uint256 taxAmount;
        uint256 revShareAmount;

        if (tax == ds._finalBuyTax) {
            taxAmount = (amount * 3) / 5;
            revShareAmount = (amount * 2) / 5;
        } else if (tax == _initialBuyTax) {
            taxAmount = (amount * 17) / 20;
            revShareAmount = (amount * 3) / 20;
        }

        ds._taxWallet.transfer(taxAmount);
        ds._revShare.transfer(revShareAmount);
    }
}
