// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://well3.com/
    Twitter:  https://twitter.com/well3official
    Discord:  https://discord.com/invite/yogapetz

*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tokename;
    }
}
