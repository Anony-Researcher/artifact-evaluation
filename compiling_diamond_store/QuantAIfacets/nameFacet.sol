/*

✈️Telegram: https://t.me/quantagi

✅Website:  https://quantagi.app

🚀X: https://x.com/TheQuantAI

*/

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract nameFacet {
    function name() public view virtual returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._name;
    }
}
