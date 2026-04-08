// SPDX-License-Identifier: UNLICENSED

/*  W3B Frens is a pioneering company in the field of NFT IP Licensing.
 *   W3B Frens specializes in facilitating the licensing of intellectual property (IP) rights
 *   through the use of non-fungible tokens (NFTs).
 */

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract isBlacklistedFacet {
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

    function isBlacklisted(address target) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.blacklist[target];
    }
}
