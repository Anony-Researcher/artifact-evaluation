// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.aiarena.io/
    Twitter:  https://twitter.com/aiarena_
    Discord:  https://discord.gg/aiarena
*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tokename;
    }
}
