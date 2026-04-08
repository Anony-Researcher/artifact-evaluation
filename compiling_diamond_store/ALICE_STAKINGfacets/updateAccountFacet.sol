pragma solidity 0.8.9;
import "./TestLib.sol";
contract updateAccountFacet {
    using SafeMath for uint256;
    using EnumerableSet for EnumerableSet.AddressSet;

    event RewardsTransferred(address holder, uint256 amount);
    function updateAccount(address account) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 pendingDivs = getPendingDivs(account);
        uint256 conbalance = Token(ds.alice).balanceOf(address(this));
        uint256 sur = conbalance.sub(ds.totalstaked);
        ds.lastClaimedTime[account] = block.timestamp;

        if (sur >= pendingDivs) {
            if (pendingDivs != 0) {
                ds.totalEarnedTokens[account] = ds
                    .totalEarnedTokens[account]
                    .add(pendingDivs);
                ds.totalClaimedRewards = ds.totalClaimedRewards.add(
                    pendingDivs
                );

                Token(ds.alice).transfer(account, pendingDivs);
                emit RewardsTransferred(account, pendingDivs);
            }
        }
    }
    function getPendingDivs(
        address _holder
    ) public view returns (uint256 _pendingDivs) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds.holders.contains(_holder)) return 0;
        if (!ds.holders.contains(_holder)) return 0;
        if (
            block.timestamp.sub(ds.stakingTime[msg.sender]) <=
            ds.MinimumWithdrawTime
        ) return 0;

        uint256 timeDiff = block.timestamp.sub(ds.lastClaimedTime[_holder]);
        uint256 stakedAmount = ds.depositedTokens[_holder];

        uint256 pendingDivs = stakedAmount
            .mul(ds.rewardRate)
            .mul(timeDiff)
            .div(ds.rewardInterval)
            .div(1e2);
        return pendingDivs;
    }
    function deposit(uint256 amountToStake) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        Token(ds.alice).transferFrom(msg.sender, address(this), amountToStake);
        updateAccount(msg.sender);
        ds.stakingTime[msg.sender] = block.timestamp;
        ds.depositedTokens[msg.sender] = ds.depositedTokens[msg.sender].add(
            amountToStake
        );
        ds.totalstaked = ds.totalstaked.add(amountToStake);
        if (!ds.holders.contains(msg.sender)) {
            ds.holders.add(msg.sender);
        }
        ds.lastETHtime[msg.sender] = block.timestamp;
    }
    function withdraw(uint256 amountToWithdraw) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.depositedTokens[msg.sender] >= amountToWithdraw,
            "Invalid amount to withdraw"
        );
        claimtheETH(msg.sender);
        ds.depositedTokens[msg.sender] = ds.depositedTokens[msg.sender].sub(
            amountToWithdraw
        );
        ds.totalstaked = ds.totalstaked.sub(amountToWithdraw);
        if (
            ds.holders.contains(msg.sender) &&
            ds.depositedTokens[msg.sender] == 0
        ) {
            ds.holders.remove(msg.sender);
        }

        uint256 _lastClaimedTime = block.timestamp.sub(
            ds.stakingTime[msg.sender]
        );
        if (_lastClaimedTime >= ds.MinimumWithdrawTime) {
            require(
                Token(ds.alice).transfer(msg.sender, amountToWithdraw),
                "Could not transfer tokens."
            );
        }

        if (_lastClaimedTime < ds.MinimumWithdrawTime) {
            uint256 WithdrawFee = amountToWithdraw.div(100).mul(ds.penalty);
            uint256 amountAfterFee = amountToWithdraw.sub(WithdrawFee);
            require(
                Token(ds.alice).transfer(msg.sender, amountAfterFee),
                "Could not transfer tokens."
            );
            require(
                Token(ds.alice).transfer(ds.devAddress, WithdrawFee),
                "Could not transfer tokens."
            );
        }

        updateAccount(msg.sender);
        ds.lastETHtime[msg.sender] = block.timestamp;
    }
    function claimtheETH(address account) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            block.timestamp.sub(ds.stakingTime[account]) >=
            ds.MinimumWithdrawTime
        ) {
            uint256 eth = GetPendingETH(account);
            ds.reth = ds.reth - eth;
            ds.lastETHtime[account] = block.timestamp;
            bool success;
            (success, ) = (account).call{value: eth}("");
            ds.totalEths[account] = ds.totalEths[account] + eth;
        }
    }
    function ClaimETH() public {
        claimtheETH(msg.sender);
    }
    function GetPendingETH(
        address _holder
    ) public view returns (uint256 _pethss) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 timeDiff = block.timestamp.sub(ds.lastETHtime[_holder]);
        uint256 tdiff = (timeDiff > ds.ethpool) ? ds.ethpool : timeDiff;
        uint256 stakedAmount = ds.depositedTokens[_holder];
        uint256 _pendingeths = stakedAmount
            .mul(ds.reth)
            .mul(tdiff)
            .div(ds.totalstaked)
            .div(ds.ethpool);
        return _pendingeths;
    }
    function claimDivs() public {
        updateAccount(msg.sender);
    }
}
