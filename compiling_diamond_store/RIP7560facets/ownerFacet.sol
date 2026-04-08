/**
 *Submitted for verification at BscScan.com on 2022-05-18
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "./TestLib.sol";
contract ownerFacet is Context {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._owner == _msgSender(),
            "Ownable: caller is not the ow  ner"
        );
        _;
    }

    function owner() public view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._owner;
    }
}
