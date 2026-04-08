/*
 * SPDX-License-Identifier: MIT
 * Discord : https://discord.com/invite/2VqABVytBZ
 * Twitter : https://twitter.com/earnalliance
 * Website : https://www.earnalliance.com/
 * Facebook: https://www.facebook.com/earnalliance/
 */
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
