/**

    Website: https://hash-rent.com
    Telegram: https://t.me/HashrentPortal
    Twitter:  https://twitter.com/Hash_Rent
    Bot: https://t.me/HashrentAI_Bot


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
