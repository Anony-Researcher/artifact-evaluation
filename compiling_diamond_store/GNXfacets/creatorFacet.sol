/*────────────────────────────┐
  Developed by coinsult.net                             
 _____     _             _ _   
|     |___|_|___ ___ _ _| | |_ 
|   --| . | |   |_ -| | | |  _|
|_____|___|_|_|_|___|___|_|_|  
                               
  t.me/coinsult_tg
──────────────────────────────┘

 SPDX-License-Identifier: MIT */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract creatorFacet is ERC20 {
    using Address for address payable;

    function creator() public pure returns (string memory) {
        return "t.me/coinsult_tg";
    }
}
