/**
// SPDX-License-Identifier: MIT
*/

/*

DatabricksAI started in data science and data engineering but has since added AI. 
The company offers data warehousing and helps users analyze the data 
and uncover insights using generative AI, ML, LLMs, and more.


*/

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
