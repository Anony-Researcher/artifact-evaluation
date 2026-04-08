/*
Welcome to PEPE AII, where we're building Digital Immortality!  $PEPAI

Token: PEPAI

🔗 Useful links:
Twitter - https://twitter.com/PepeAi_onEth
Telegram - https://t.me/Pepe_Ai_Eth
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view virtual returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._name;
    }
}
