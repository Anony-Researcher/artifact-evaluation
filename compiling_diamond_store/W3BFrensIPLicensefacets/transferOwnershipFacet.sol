// SPDX-License-Identifier: UNLICENSED

/*  W3B Frens is a pioneering company in the field of NFT IP Licensing.
 *   W3B Frens specializes in facilitating the licensing of intellectual property (IP) rights
 *   through the use of non-fungible tokens (NFTs).
 */

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract transferOwnershipFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Caller is not the ds.owner");
        _;
    }
    modifier notBlacklisted() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.blacklist[msg.sender], "Caller is blacklisted");
        _;
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    function transferOwnership(address newOwner) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(newOwner != address(0), "New ds.owner is the zero address");
        emit OwnershipTransferred(ds.owner, newOwner);
        ds.owner = newOwner;
    }
}
