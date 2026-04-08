/**

SOCIAL LINK INFORMATION

Website     : https://neura-node.com/
Telegram    : https://t.me/NeuraNodeAI
Twitter     : https://twitter.com/NeuraNodeAI
Medium      : https://neuranode.medium.com/
Github      : https://github.com/NeuraNode
Youtube     : https://www.youtube.com/@NeuraNode
Tiktok      : https://www.tiktok.com/@neuranode

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
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
