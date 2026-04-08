// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;
import "./TestLib.sol";
contract toggleDepositLockFacet is Ownable {
    using SafeMath for uint256;
    using LowGasSafeMath for uint32;
    using SafeERC20 for IERC20;
    using SafeERC20 for IxVexaris;

    event LogDepositLock(address indexed user, bool locked);
    function toggleDepositLock() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.warmupInfo[msg.sender].lock = !ds.warmupInfo[msg.sender].lock;
        emit LogDepositLock(msg.sender, ds.warmupInfo[msg.sender].lock);
    }
}
