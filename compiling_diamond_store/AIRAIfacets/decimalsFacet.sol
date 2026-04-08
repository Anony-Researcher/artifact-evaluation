// SPDX-License-Identifier: MIT
/*

Airstack AI Blockchain Developer Tool

The most straightforward method for constructing modular blockchain applications.
Seamlessly incorporate both on-chain and off-chain data into any software instantly using AI.

https://www.airstack.xyz/
https://docs.airstack.xyz/airstack-docs-and-faqs
https://twitter.com/airstack_xyz
https://www.linkedin.com/company/airstack-xyz
https://app.airstack.xyz/sdks
https://warpcast.com/~/channel/airstack
https://app.airstack.xyz/api-studio

*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._swapping = true;
        _;
        ds._swapping = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
