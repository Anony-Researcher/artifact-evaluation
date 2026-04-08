/*
Get ready to Soak'em on Blast!

Website: https://www.supersoaker.xyz/
Twitter: https://twitter.com/SuperSoakerBot
TG: https://t.me/supersoaker_portal
TG Bot: https://t.me/SuperSoaker_bot

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
