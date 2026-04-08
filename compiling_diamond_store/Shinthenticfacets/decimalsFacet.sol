/**

Shinthentic AI

Revolutionizing Smart Contract Auditing with Artificial Intelligence

Website: https://www.shinthentic.com/
TG: https://t.me/Shinthentic
Twitter: https://twitter.com/shynthentic

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
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
