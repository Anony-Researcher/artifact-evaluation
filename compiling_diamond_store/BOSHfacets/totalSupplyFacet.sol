// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier onlyTaxWallet() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet, "Caller not authorized");
        _;
    }
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._inSwap = true;
        _;
        ds._inSwap = false;
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
    function openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds._tradingEnabled, "Trading already open");

        ds._uniswapV2Router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );

        _approve(address(this), address(ds._uniswapV2Router), totalSupply());

        ds._uniswapV2Pair = IUniswapV2Factory(ds._uniswapV2Router.factory())
            .createPair(address(this), ds._uniswapV2Router.WETH());

        ds._uniswapV2Router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );

        IERC20(ds._uniswapV2Pair).approve(
            address(ds._uniswapV2Router),
            type(uint256).max
        );

        ds._swapEnabled = true;
        ds._tradingEnabled = true;
        ds._launchBlock = block.number;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function _swapTokensForEth(uint256 tokenAmount) private lockTheSwap {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds._uniswapV2Router.WETH();

        _approve(address(this), address(ds._uniswapV2Router), tokenAmount);

        try
            ds
                ._uniswapV2Router
                .swapExactTokensForETHSupportingFeeOnTransferTokens(
                    tokenAmount,
                    0,
                    path,
                    address(this),
                    block.timestamp
                )
        {} catch {}
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        uint256 taxAmount = 0;

        if (
            ds._tradingEnabled &&
            ds._limitsEnabled &&
            block.number > ds._launchBlock.add(ds._disableLimitsAfterBlock)
        ) {
            _disableLimits();
        }

        if (from != owner() && to != owner()) {
            taxAmount = amount
                .mul(
                    (ds._buyCount > ds._reduceBuyTaxAt)
                        ? ds._finalBuyTax
                        : ds._initialBuyTax
                )
                .div(100);

            if (
                from == ds._uniswapV2Pair &&
                to != address(ds._uniswapV2Router) &&
                !ds._isExcludedFromFee[to]
            ) {
                require(amount <= ds._maxTxAmount, "Exceeds the max TX amount");
                require(
                    balanceOf(to) + amount <= ds._maxWalletAmount,
                    "Exceeds the max wallet amount"
                );

                ds._buyCount++;
            }

            if (to != ds._uniswapV2Pair && !ds._isExcludedFromFee[to]) {
                require(
                    balanceOf(to) + amount <= ds._maxWalletAmount,
                    "Exceeds the max wallet amount"
                );
            }

            if (to == ds._uniswapV2Pair && from != address(this)) {
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
                !ds._inSwap &&
                to == ds._uniswapV2Pair &&
                ds._swapEnabled &&
                ds._buyCount > ds._preventSwapBefore &&
                contractTokenBalance > ds._swapThresholdAmount
            ) {
                if (block.number > ds._lastSellBlock) {
                    ds._sellCount = 0;
                }

                require(
                    ds._sellCount < ds._maxSellsPerBlock,
                    "Max sells per block exceeded"
                );

                ds._sellCount++;
                ds._lastSellBlock = block.number;

                _swapTokensForEth(
                    _min(amount, _min(contractTokenBalance, ds._maxSwapAmount))
                );

                _sendETHToFee();
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
    function _disableLimits() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = totalSupply();
        ds._maxWalletAmount = totalSupply();

        ds._limitsEnabled = false;
    }
    function disableLimits() external onlyTaxWallet {
        _disableLimits();
    }
    function _min(uint256 a, uint256 b) private pure returns (uint256) {
        return (a > b) ? b : a;
    }
    function _sendETHToFee() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 contractETHBalance = address(this).balance;

        if (contractETHBalance == 0) {
            return;
        }

        bool success;
        (success, ) = address(ds._taxWallet).call{value: contractETHBalance}(
            ""
        );
    }
    function manualSwap() external onlyTaxWallet {
        uint256 contractTokenBalance = balanceOf(address(this));

        if (contractTokenBalance > 0) {
            _swapTokensForEth(contractTokenBalance);

            _sendETHToFee();
        }
    }
    function manualSendETH() external onlyTaxWallet {
        _sendETHToFee();
    }
    function manualSendTokens(uint256 tokenAmount) external onlyTaxWallet {
        require(
            tokenAmount <= balanceOf(address(this)),
            "Transfer amount exceeds balance"
        );

        IERC20(address(this)).transfer(_msgSender(), tokenAmount);
    }
}
