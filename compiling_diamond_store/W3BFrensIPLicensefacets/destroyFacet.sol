// SPDX-License-Identifier: UNLICENSED

/*  W3B Frens is a pioneering company in the field of NFT IP Licensing.
 *   W3B Frens specializes in facilitating the licensing of intellectual property (IP) rights
 *   through the use of non-fungible tokens (NFTs).
 */

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract destroyFacet {
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

    function destroy() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.destroyTime != 0, "Destroy time not set");
        require(
            block.timestamp >= ds.destroyTime,
            "Destroy time has not been reached"
        );

        if (address(this).balance > 0) {
            payable(ds.owner).transfer(address(this).balance);
        }

        ds.active = false;
    }
}
