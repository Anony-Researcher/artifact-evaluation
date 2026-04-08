// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view virtual returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._symbol;
    }
}
