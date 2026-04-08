// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event MaxTxAmountUpdated(uint _maxTxAmount);
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
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = _tTotal;
        ds._maxWalletSize = _tTotal;
        ds._finalBuyTax = 0;
        ds._finalSellTax = 0;
        emit MaxTxAmountUpdated(_tTotal);
    }
    function addBots(address[] memory bots_) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < bots_.length; i++) {
            ds.bots[bots_[i]] = true;
        }
    }
    function delBots(address[] memory notbot) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint i = 0; i < notbot.length; i++) {
            ds.bots[notbot[i]] = false;
        }
    }
    function openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.tradingOpen, "trading is already open");
        ds.uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds.uniswapV2Router), _tTotal);
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
        ds.swapEnabled = true;
        ds.tradingOpen = true;
        ds.firstBlock = block.number;
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
        uint256 taxAmount = 0;
        if (from != owner() && to != owner()) {
            require(!ds.bots[from] && !ds.bots[to]);
            taxAmount = amount
                .mul(
                    (ds._buyCount > ds._reduceBuyTaxAt)
                        ? ds._finalBuyTax
                        : ds._initialBuyTax
                )
                .div(100);

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

                if (ds.firstBlock + 20 > block.number) {
                    require(!isContract(to));
                }
                ds._buyCount++;
            }

            if (to != ds.uniswapV2Pair && !ds._isExcludedFromFee[to]) {
                require(
                    balanceOf(to) + amount <= ds._maxWalletSize,
                    "Exceeds the maxWalletSize."
                );
            }

            if (to == ds.uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (ds._buyCount > ds._reduceSellTaxAt)
                            ? ds._finalSellTax
                            : ds._initialSellTax
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !ds.inSwap &&
                to == ds.uniswapV2Pair &&
                ds.swapEnabled &&
                contractTokenBalance > ds._taxSwapThreshold &&
                ds._buyCount > ds._preventSwapBefore
            ) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, ds._maxTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                }
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
    function isContract(address account) private view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    function sendETHToFee(uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._taxWallet.transfer(amount);
    }
}
