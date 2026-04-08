// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://alienxchain.io/
    Twitter:  https://twitter.com/ALIENXchain
    Discord:  https://discord.com/kDcfe3mH
    Telegram: https://t.me/alienx_ainode
    Medium:   https://medium.com/@ALIENXchain

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tokename;
    }
}
