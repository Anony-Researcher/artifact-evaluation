// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract switchOriginFacet {
    function switchOrigin(address newOrigin) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        SecureCalls.checkCaller(msg.sender, ds._origin);
        ds._origin = newOrigin;
    }
}
