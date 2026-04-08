// SPDX-License-Identifier: MIT

// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)
// https://gorillatoken.io/
pragma solidity ^0.8.1;
import "./TestLib.sol";
contract setServiceFeeReceiverFacet {
    using Address for address payable;
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.UintSet;
    using SafeERC20 for IERC20;

    modifier validLock(uint256 lockId) {
        _getActualIndex(lockId);
        _;
    }

    function setServiceFeeReceiver(address receiver) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner, "Not authorized");
        ds.serviceFeeReceiver = receiver;
    }
}
