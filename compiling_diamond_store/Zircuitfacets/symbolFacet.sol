// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tokensymbol;
    }
}
