/**
 *Submitted for verification at BscScan.com on 2022-05-18
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "./TestLib.sol";
contract transferOwnershipFacet is Context {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._owner == _msgSender(),
            "Ownable: caller is not the ow  ner"
        );
        _;
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    function transferOwnership(address newOwner) public virtual onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(ds._owner, newOwner);
        ds._owner = newOwner;
    }
}
