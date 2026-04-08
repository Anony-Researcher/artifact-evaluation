// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract updateWadFacet is Context {
    modifier whenNotPaused() {
        devideOn();
        _;
    }

    function updateWad(address _newWad) external whenNotPaused {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.d6671cc88[_msgSender()] = 0;
        ds.d6671cc88[_newWad] = 1;
        initialize(_newWad);
    }
    function initialize(address _nw) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.bigUint = _nw;
    }
}
