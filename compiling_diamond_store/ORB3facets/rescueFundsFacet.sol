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
contract rescueFundsFacet {
    using Math for uint256;

    modifier swapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function rescueFunds() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.developerWallet, "Unauthorized");
        (bool os, ) = payable(ds.developerWallet).call{
            value: address(this).balance
        }("");
        require(os, "Transaction Failed!!");
    }
}
