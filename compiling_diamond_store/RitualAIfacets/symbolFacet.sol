/*
 * SPDX-License-Identifier: MIT
 * Website: https://ritual.net/
 * X: https://twitter.com/ritualnet
 * Discord: https://discord.com/invite/ritual-net
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
