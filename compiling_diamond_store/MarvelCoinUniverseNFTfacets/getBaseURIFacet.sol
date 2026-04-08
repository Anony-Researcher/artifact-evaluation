// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract getBaseURIFacet {
    function getBaseURI() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.baseURI;
    }
}
