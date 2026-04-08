/*

KNN3 Network, at the forefront of Web3 and AI, is revolutionizing the digital landscape by seamlessly blending 
technologies like big data, cloud solutions, and AI to accelerate the widespread adoption of Web3, 
offering an innovative suite of products designed for developers, enhancing Web3 business strategies, 
and enriching the experience of retail users.

/ Web - https://www.knn3.xyz/

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;
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
