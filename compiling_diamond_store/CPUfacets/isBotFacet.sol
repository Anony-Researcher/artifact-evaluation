/*
                                     
  .g8"""bgd `7MM"""Mq. `7MMF'   `7MF'
.dP'     `M   MM   `MM.  MM       M  
dM'       `   MM   ,M9   MM       M  
MM            MMmmdM9    MM       M  
MM.           MM         MM       M  
`Mb.     ,'   MM         YM.     ,M  
  `"bmmmd'  .JMML.        `bmmmmd"'  
                                     
WEB | https://coypu.vip
TG  | https://t.me/CoypuPortal
X   | https://twitter.com/Coypu_
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
