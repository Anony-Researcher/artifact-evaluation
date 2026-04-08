/*
Grid Pixel Render - Advancing the GPU Marketplace

Intro: Grid Pixel Render stands at the forefront of the GPU marketplace, offering an innovative
platform for the trading, leasing, and procurement of GPU and node resources. With
GPR, we introduce a revenue-sharing model that benefits token holders, setting a new
standard in the decentralized access to computational power. GPR addresses the rising
demand for accessible, scalable, and efficient computing resources, offering solutions
that cater to various sectors including AI, machine learning, and blockchain
development.

Overview: Utilizing blockchain technology, GPR ensures a transparent, automated, and secure
environment for transactions involving GPU resources. Built on the Ethereum blockchain,
our platform provides users with a reliable, scalable solution that integrates seamlessly
with existing decentralized applications, enhancing the computational capabilities of the
blockchain ecosystem.

More Info: 
WEB | https://gridpixelrender.com
TG  | https://t.me/GridPixelRender
X   | https://twitter.com/GridPixelRender
Whitepaper | https://gridpixelrender.com/wp-content/uploads/2024/03/whitepaper.pdf
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract isBotFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isBot(address a) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.bots[a];
    }
}
