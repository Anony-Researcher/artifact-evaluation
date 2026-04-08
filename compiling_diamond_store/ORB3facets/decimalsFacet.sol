/**

     ## ##   ### ##   ### ##    ## ##   
    ##   ##   ##  ##   ##  ##  ##   ##  
    ##   ##   ##  ##   ##  ##       ##  
    ##   ##   ## ##    ## ##      ###   
    ##   ##   ## ##    ##  ##       ##  
    ##   ##   ##  ##   ##  ##  ##   ##  
     ## ##   #### ##  ### ##    ## ##   

Telegram: https://link3.to/orb3pro
Twitter:  https://twitter.com/Orb3Tech
Website:  https://orb3.tech

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;
import "./TestLib.sol";
contract decimalsFacet {
    using Math for uint256;

    modifier swapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public view returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._decimals;
    }
}
