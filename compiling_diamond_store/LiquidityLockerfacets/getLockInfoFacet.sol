/**
 */

// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/utils/math/SafeMath.sol

// OpenZeppelin Contracts (last updated v4.9.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract getLockInfoFacet {
    using SafeMath for uint256;

    function getLockInfo(
        IERC20 _token
    )
        public
        view
        returns (
            uint256 amount,
            uint256 unlockTime,
            address owner,
            bool isLocked
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.Locker storage locker = ds.liquidityLocks[_token];
        amount = locker.amount;
        unlockTime = locker.unlockTime;
        owner = locker.owner;
        isLocked = locker.unlockTime > block.timestamp;
    }
}
