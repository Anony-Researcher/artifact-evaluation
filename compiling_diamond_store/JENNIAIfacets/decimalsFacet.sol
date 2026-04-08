// SPDX-License-Identifier: MIT
/**

Experience the future of blockchain conversations with Jenni AI. Harness the power of our advanced AI smart contracts for smooth and efficient deployments. Explore our features now.

Telegram: https://t.me/MeetJenni
Twitter: https://twitter.com/MeetJenni
Website: https://www.meetjenni.com

**/
pragma solidity ^0.8.19;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._inSwap = true;
        _;
        ds._inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
