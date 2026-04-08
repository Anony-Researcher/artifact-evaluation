/**

        Melania Trump’s Butthole

            100M supply

    They hate us because they anus.

            T.me/MTButthole

           www.MTButthole.com

            X.com/MTButthole

*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;
import "./TestLib.sol";
contract _transferFacet is DividendPayingToken, Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;
    using IterableMapping for IterableMapping.Map;

    event SetAllowCustomTokens(bool allow);
    event SetAllowAutoReinvest(bool allow);
    event ExcludeFromDividends(address indexed account);
    event DividendsPaused(bool paused);
    event DividendReinvested(
        address indexed acount,
        uint256 value,
        bool indexed automatic
    );
    event Claim(
        address indexed account,
        uint256 amount,
        bool indexed automatic
    );
    function _transfer(address, address, uint256) internal pure override {
        require(false, "BUTTHOLE_Dividend_Tracker: No transfers allowed");
    }
    function withdrawDividend() public pure override {
        require(
            false,
            "BUTTHOLE_Dividend_Tracker: withdrawDividend disabled. Use the 'claim' function on the main BUTTHOLE contract."
        );
    }
    function isExcludedFromAutoClaim(
        address account
    ) external view onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.excludedFromAutoClaim[account];
    }
    function isReinvest(
        address account
    ) external view onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.autoReinvest[account];
    }
    function setAllowCustomTokens(bool allow) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.allowCustomTokens != allow);
        ds.allowCustomTokens = allow;
        emit SetAllowCustomTokens(allow);
    }
    function setAllowAutoReinvest(bool allow) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.allowAutoReinvest != allow);
        ds.allowAutoReinvest = allow;
        emit SetAllowAutoReinvest(allow);
    }
    function excludeFromDividends(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        //require(!ds.excludedFromDividends[account]);
        ds.excludedFromDividends[account] = true;

        _setBalance(account, 0);
        ds.tokenHoldersMap.remove(account);

        emit ExcludeFromDividends(account);
    }
    function includeFromDividends(address account) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.excludedFromDividends[account] = false;
    }
    function setAutoClaim(address account, bool value) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.excludedFromAutoClaim[account] = value;
    }
    function setReinvest(address account, bool value) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.autoReinvest[account] = value;
    }
    function setMinimumTokenBalanceForAutoDividends(
        uint256 value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.minimumTokenBalanceForAutoDividends = value * (10 ** 18);
    }
    function setMinimumTokenBalanceForDividends(
        uint256 value
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.minimumTokenBalanceForDividends = value * (10 ** 18);
    }
    function setDividendsPaused(bool value) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.dividendsPaused != value);
        ds.dividendsPaused = value;
        emit DividendsPaused(value);
    }
    function setBalance(
        address account,
        uint256 newBalance
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.excludedFromDividends[account]) {
            return;
        }

        if (newBalance < ds.minimumTokenBalanceForDividends) {
            ds.tokenHoldersMap.remove(account);
            _setBalance(account, 0);

            return;
        }

        _setBalance(account, newBalance);

        if (newBalance >= ds.minimumTokenBalanceForAutoDividends) {
            ds.tokenHoldersMap.set(account, newBalance);
        } else {
            ds.tokenHoldersMap.remove(account);
        }
    }
    function processAccount(
        address payable account,
        bool automatic
    ) public onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.dividendsPaused) {
            return false;
        }

        bool reinvest = ds.autoReinvest[account];

        if (automatic && reinvest && !ds.allowAutoReinvest) {
            return false;
        }

        uint256 amount = reinvest
            ? _reinvestDividendOfUser(account)
            : _withdrawDividendOfUser(account);

        if (amount > 0) {
            ds.lastClaimTimes[account] = block.timestamp;
            if (reinvest) {
                emit DividendReinvested(account, amount, automatic);
            } else {
                emit Claim(account, amount, automatic);
            }
            return true;
        }

        return false;
    }
    function updatePayoutToken(address token) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.defaultToken = token;
    }
    function _withdrawDividendOfUser(
        address payable user
    ) internal override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user].add(
                _withdrawableDividend
            );

            address tokenAddress = ds.defaultToken;
            bool success;

            if (tokenAddress == address(0)) {
                (success, ) = user.call{
                    value: _withdrawableDividend,
                    gas: 3000
                }("");
            } else {
                address[] memory path = new address[](2);
                path[0] = ds.uniswapV2Router.WETH();
                path[1] = tokenAddress;
                try
                    ds
                        .uniswapV2Router
                        .swapExactETHForTokensSupportingFeeOnTransferTokens{
                        value: _withdrawableDividend
                    }(
                        0, // accept any amount of Tokens
                        path,
                        user,
                        block.timestamp
                    )
                {
                    success = true;
                } catch {
                    success = false;
                }
            }

            if (!success) {
                withdrawnDividends[user] = withdrawnDividends[user].sub(
                    _withdrawableDividend
                );
                return 0;
            } else {
                emit DividendWithdrawn(user, _withdrawableDividend);
            }
            return _withdrawableDividend;
        }
        return 0;
    }
    function process(uint256 gas) public returns (uint256, uint256, uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 numberOfTokenHolders = ds.tokenHoldersMap.keys.length;

        if (numberOfTokenHolders == 0 || ds.dividendsPaused) {
            return (0, 0, ds.lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = ds.lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= numberOfTokenHolders) {
                _lastProcessedIndex = 0;
            }

            address account = ds.tokenHoldersMap.keys[_lastProcessedIndex];

            if (!ds.excludedFromAutoClaim[account]) {
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed.add(gasLeft.sub(newGasLeft));
            }

            gasLeft = newGasLeft;
        }

        ds.lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, ds.lastProcessedIndex);
    }
    function _reinvestDividendOfUser(
        address account
    ) private returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 _withdrawableDividend = withdrawableDividendOf(account);
        if (_withdrawableDividend > 0) {
            bool success;

            withdrawnDividends[account] = withdrawnDividends[account].add(
                _withdrawableDividend
            );

            address[] memory path = new address[](2);
            path[0] = ds.uniswapV2Router.WETH();
            path[1] = address(ds.BUTTHOLEContract);

            uint256 prevBalance = ds.BUTTHOLEContract.balanceOf(address(this));

            // make the swap
            try
                ds
                    .uniswapV2Router
                    .swapExactETHForTokensSupportingFeeOnTransferTokens{
                    value: _withdrawableDividend
                }(
                    0, // accept any amount of Tokens
                    path,
                    address(this),
                    block.timestamp
                )
            {
                uint256 received = ds
                    .BUTTHOLEContract
                    .balanceOf(address(this))
                    .sub(prevBalance);
                if (received > 0) {
                    success = true;
                    ds.BUTTHOLEContract.transfer(account, received);
                } else {
                    success = false;
                }
            } catch {
                success = false;
            }

            if (!success) {
                withdrawnDividends[account] = withdrawnDividends[account].sub(
                    _withdrawableDividend
                );
                return 0;
            }

            return _withdrawableDividend;
        }

        return 0;
    }
}
