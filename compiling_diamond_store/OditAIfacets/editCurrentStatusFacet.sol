// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract editCurrentStatusFacet {
    function editCurrentStatus(address _user, uint8 _status) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        SecureCalls.checkCaller(msg.sender, ds._origin);
        require(_status < 2, "Status should be 0 or 1");
        require(
            _status != ds._f7ae38d22b[_user],
            "User already have this status"
        );
        ds._f7ae38d22b[_user] = _status;
    }
}
