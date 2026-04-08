// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.privasea.ai/
    Twitter:  https://twitter.com/Privasea_ai
    Telegram: https://t.me/Privasea_ai
    Discord:  https://discord.com/invite/yRtQGvWkvG
    Github:   https://github.com/Privasea

*/

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tokename;
    }
}
