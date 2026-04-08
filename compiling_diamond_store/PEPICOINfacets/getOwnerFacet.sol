/**
 *Submitted for verification at Etherscan.io on 2023-11-19
 */

//SPDX-License-Identifier: Unlicensed

/* 

 _______  _______  _______  ___  
|       ||       ||       ||   | 
|    _  ||    ___||    _  ||   | 
|   |_| ||   |___ |   |_| ||   | 
|    ___||    ___||    ___||   | 
|   |    |   |___ |   |    |   | 
|___|    |_______||___|    |___| 

*/

pragma solidity 0.8.21;
import "./TestLib.sol";
contract getOwnerFacet is Ownable {
    using SafeMath for uint256;

    modifier swapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function getOwner() external view returns (address) {
        return owner();
    }
}
