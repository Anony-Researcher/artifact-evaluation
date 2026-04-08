/* 



/*

/*
Joni us on this adventurous Journey.
https://twitter.com/DominoDataLab
https://domino.ai/

Domino is the Enterprise MLOps platform trusted by over 20% of the Fortune 100. 
Our products enable thousands of data scientists to develop better medicines, grow more productive crops, adapt risk models to major economic shifts, 
build better cars, improve customer support, or simply recommend the best purchase to make at the right time. 
At Domino,our mission is to unleash the power of data science to address the world’s most important challenges.

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
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
