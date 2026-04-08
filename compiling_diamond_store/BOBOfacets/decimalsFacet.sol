/**
 
*/

/**
    Bobo 2.0 is designed to build upon the success of its predecessor while incorporating advanced features and improvements. 
    The platform focuses on delivering a secure, user-friendly, and highly accessible environment for all participants, 
    regardless of their financial background or expertise.
    - https://t.me/Bobo20ETH
    - https://medium.com/@Bobo2.0
    - https://twitter.com/Bobo20Erc
    - https://www.bobo2-0.com/
// SPDX-License-Identifier: MIT
/*
*/
pragma solidity 0.8.24;
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
