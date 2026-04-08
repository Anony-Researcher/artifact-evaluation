/*
 * SPDX-License-Identifier: MIT
 * Website: https://well3.com/
 * X: https://twitter.com/well3official
 * Discord: https://discord.gg/yogapetz
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
