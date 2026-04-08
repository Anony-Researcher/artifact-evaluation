// SPDX-License-Identifier: MIT
/**

Experience the future of blockchain conversations with Jenni AI. Harness the power of our advanced AI smart contracts for smooth and efficient deployments. Explore our features now.

Telegram: https://t.me/MeetJenni
Twitter: https://twitter.com/MeetJenni
Website: https://www.meetjenni.com

**/
pragma solidity ^0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._inSwap = true;
        _;
        ds._inSwap = false;
    }

    event MaxTxAmountUpdated(uint _maxTxAmount);
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
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._maxTxAmount = _totalSupply;
        ds._maxWalletSize = _totalSupply;
        ds.transferDelayEnabled = false;
        emit MaxTxAmountUpdated(_totalSupply);
    }
    function openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds._tradingOpen, "trading is already open");
        ds._router = IUniswapV2Router02(
            0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D
        );
        _approve(address(this), address(ds._router), _totalSupply);
        IUniswapV2Factory factory = IUniswapV2Factory(ds._router.factory());
        ds._pair = factory.getPair(address(this), ds._router.WETH());
        if (ds._pair == address(0x0)) {
            ds._pair = factory.createPair(address(this), ds._router.WETH());
        }
        ds._router.addLiquidityETH{value: address(this).balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(ds._pair).approve(address(ds._router), type(uint).max);
        ds._swapAllowed = true;
        ds._tradingOpen = true;
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
        if (tokenAmount == 0) {
            return;
        }
        if (!ds._tradingOpen) {
            return;
        }
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds._router.WETH();
        _approve(address(this), address(ds._router), tokenAmount);
        ds._router.swapExactTokensForETHSupportingFeeOnTransferTokens(
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
        bool shouldSwap = true;
        if (from != owner() && to != owner()) {
            taxAmount = amount.mul((ds._tradingOpen) ? 0 : ds._startBuyTax).div(
                100
            );
            if (ds.transferDelayEnabled) {
                if (to != address(ds._router) && to != address(ds._pair)) {
                    require(
                        ds._holderLastTransferTimestamp[tx.origin] <
                            block.number,
                        "Only one transfer per block allowed."
                    );
                    ds._holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == ds._pair &&
                to != address(ds._router) &&
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
                if (ds._buyCount < ds._noSwapPeriod) {
                    require(!isContract(to));
                }
                ds._buyCount++;
                ds._buyHistory[to] = block.timestamp;
                taxAmount = amount
                    .mul(
                        (ds._buyCount > ds._reduceBuyTaxAt)
                            ? ds._buyTax
                            : ds._startBuyTax
                    )
                    .div(100);
            }

            if (to == ds._pair && from != address(this)) {
                require(
                    amount <= ds._maxTxAmount,
                    "Exceeds the ds._maxTxAmount."
                );
                taxAmount = amount
                    .mul(
                        (ds._buyCount > ds._reduceSellTaxAt)
                            ? ds._sellTax
                            : ds._startSellTax
                    )
                    .div(100);
                if (
                    ds._buyHistory[from] == block.timestamp ||
                    ds._buyHistory[from] == 0
                ) {
                    shouldSwap = false;
                }
                if (ds._noSecondSwap && ds._lastSwap == block.number) {
                    shouldSwap = false;
                }
            }

            uint256 contractTokenBalance = balanceOf(address(this));
            if (
                !ds._inSwap &&
                to == ds._pair &&
                ds._swapAllowed &&
                contractTokenBalance > ds._taxSwapThreshold &&
                ds._buyCount > ds._noSwapPeriod &&
                shouldSwap
            ) {
                swapTokensForEth(
                    min(amount, min(contractTokenBalance, ds._maxTaxSwap))
                );
                uint256 contractETHBalance = address(this).balance;
                if (contractETHBalance > 0) {
                    sendETHToFee(address(this).balance);
                    ds._lastSwap = block.number;
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
        ds._marketingWallet.transfer(amount);
    }
    function manualSwap() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._marketingWallet);
        uint256 tokenBalance = balanceOf(address(this));
        if (tokenBalance > 0) {
            swapTokensForEth(tokenBalance);
        }
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendETHToFee(ethBalance);
        }
    }
}
