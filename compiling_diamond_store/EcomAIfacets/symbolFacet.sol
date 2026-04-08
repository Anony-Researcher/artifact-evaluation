/**
website}
 https://ecomai.tech}
{twitter} https://twitter.com/EcomaiERC
{Doc}
https://ecom-ai.gitbook.io/ecom-ai-whitepaper
{Medium} 
https://medium.com/@EcomAIERC

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
