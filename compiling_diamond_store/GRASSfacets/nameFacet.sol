/**
    Powered by Wynd Network
    https://www.wyndlabs.ai/

    Wynd Network, blending blockchain technology with AI, focuses on decentralized AI projects. 
    Their main product, Grass, is a decentralized web scraping network that transforms public web data into AI datasets. 
    This process, utilizing millions of home internet connections, is crucial for AI model development across various sectors. 
    Grass serves as a decentralized AI oracle, providing transparent and fairly compensated datasets.
    
    https://app.getgrass.io/
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import "./TestLib.sol";
contract nameFacet {
    function name() public pure returns (string memory) {
        return _name;
    }
}
