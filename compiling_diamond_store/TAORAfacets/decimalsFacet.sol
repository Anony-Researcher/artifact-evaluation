/**


// Website: https://taora.xyz
// Telegram: https://t.me/BittensorOracle
// X: https://twitter.com/BittensorOracle
// Docs: https://docs.taora.xyz/

*/

// SPDX-License-Identifier: Unlicensed

pragma solidity ^0.8.4;
import "./TestLib.sol";
contract decimalsFacet {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
