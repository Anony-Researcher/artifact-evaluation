/*  
   * SPDX-License-Identifier: MIT 

    // Twitter: https://twitter.com/pacmoon_
    // Website: https://pacmoon.io/
    // Telegram: https://t.me/PacMoon_PAC
   

*/
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
