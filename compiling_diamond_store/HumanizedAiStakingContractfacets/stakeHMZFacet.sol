// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract stakeHMZFacet {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.owner,
            "Only the ds.owner can call this function."
        );
        _;
    }

    function stakeHMZ(uint256 amount, uint256 duration) external noReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            duration == 14 ||
                duration == 30 ||
                duration == 90 ||
                duration == 180 ||
                duration == 365,
            "Invalid duration"
        );
        require(
            ds.stakes[msg.sender][1].amount == 0,
            "Already HMZ Token deposited"
        );
        ds.token.transferFrom(msg.sender, address(this), amount);
        ds.stakes[msg.sender][1] = TestLib.Stake(
            1,
            amount,
            duration,
            getMultiplier(1, duration),
            block.timestamp
        );
    }
    function stakeETH(uint256 duration) external payable noReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            duration == 14 ||
                duration == 30 ||
                duration == 90 ||
                duration == 180 ||
                duration == 365,
            "Invalid duration"
        );
        require(ds.stakes[msg.sender][2].amount == 0, "Already ETH deposited");
        ds.stakes[msg.sender][2] = TestLib.Stake(
            2,
            msg.value,
            duration,
            getMultiplier(2, duration),
            block.timestamp
        );
    }
    function stakeUSDT(uint256 amount, uint256 duration) external noReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            duration == 14 ||
                duration == 30 ||
                duration == 90 ||
                duration == 180 ||
                duration == 365,
            "Invalid duration"
        );
        require(
            ds.stakes[msg.sender][3].amount == 0,
            "Already ds.USDT deposited"
        );
        ds.USDT.safeTransferFrom(msg.sender, address(this), amount);
        ds.stakes[msg.sender][3] = TestLib.Stake(
            3,
            amount,
            duration,
            getMultiplier(3, duration),
            block.timestamp
        );
    }
    function withdrawToken(address withdrawer) external noReentrant onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tokenBalance = ds.token.balanceOf(address(this));
        require(tokenBalance > 0, "No tokens to withdraw");
        ds.token.transfer(withdrawer, tokenBalance);
    }
    function withdrawUSDT(address withdrawer) external noReentrant onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tokenBalance = ds.USDT.balanceOf(address(this));
        require(tokenBalance > 0, "No tokens to withdraw");
        ds.USDT.safeTransfer(withdrawer, tokenBalance);
    }
    function withdrawBalance(
        address withdrawer
    ) external noReentrant onlyOwner {
        uint256 contractBalance = address(this).balance;
        require(contractBalance > 0, "No ETH balance to withdraw");
        (bool success, ) = payable(withdrawer).call{value: contractBalance}("");
        require(success, "ETH withdrawal failed");
    }
    function unstake(uint256 index) external noReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 reward = calculateReward(msg.sender, index);
        require(reward > 0, "No reward available");
        TestLib.Stake storage iStakes = ds.stakes[msg.sender][index];
        if (index == 1) {
            ds.token.transfer(msg.sender, reward);
            iStakes.amount = 0;
        } else if (index == 2) {
            (bool success, ) = payable(msg.sender).call{value: reward}("");
            require(success, "ETH withdrawal failed");
            iStakes.amount = 0;
        } else if (index == 3) {
            ds.USDT.safeTransfer(msg.sender, reward);
            iStakes.amount = 0;
        }
    }
    function calculateReward(
        address account,
        uint256 index
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.stakes[account][index].amount <= 0) {
            return 0;
        }
        TestLib.Stake memory stake = ds.stakes[account][index];
        uint256 endTime = stake.startTime + (stake.duration * 1 days);
        if (block.timestamp >= endTime) {
            return stake.amount + (stake.amount * stake.multiplier) / 100;
        } else {
            return 0;
        }
    }
    function getMultiplier(
        uint256 stakeType,
        uint256 duration
    ) internal pure returns (uint256) {
        if (stakeType == 1) {
            if (duration == 14) {
                return 5;
            } else if (duration == 30) {
                return 11;
            } else if (duration == 90) {
                return 40;
            } else if (duration == 180) {
                return 100;
            } else if (duration == 365) {
                return 250;
            }
        } else {
            if (duration == 14) {
                return 3;
            } else if (duration == 30) {
                return 5;
            } else if (duration == 90) {
                return 12;
            } else if (duration == 180) {
                return 30;
            } else if (duration == 365) {
                return 75;
            }
        }
        return 0;
    }
}
