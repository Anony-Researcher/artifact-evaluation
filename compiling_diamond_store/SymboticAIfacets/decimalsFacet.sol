/**
// SPDX-License-Identifier: MIT
*/

/*

Symbotic.AI specializes in AI-powered robotic warehouse automation. Symbotic’s 
client list includes some true retail giants, such as Walmart, 
Target and Albertsons. With the company’s AI software and advanced robotics, 
Symbotic is hoping to solve several supply chain-related problems,
including limited labor availability, growing operating costs and SKU proliferation.

*/

pragma solidity 0.8.20;
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
