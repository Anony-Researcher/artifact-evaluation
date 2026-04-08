/*  
   * SPDX-License-Identifier: MIT
    ▫️Website: https://dappad.app
    ▫️Twitter: https://twitter.com/Dappadofficial
    ▫️Discord: https://discord.gg/dappadlaunchpad
    ▫️Github: https://github.com/dappadapp
*/
pragma solidity ^0.8.19;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
