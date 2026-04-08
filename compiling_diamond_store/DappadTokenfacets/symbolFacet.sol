/*  
   * SPDX-License-Identifier: MIT
    ▫️Website: https://dappad.app
    ▫️Twitter: https://twitter.com/Dappadofficial
    ▫️Discord: https://discord.gg/dappadlaunchpad
    ▫️Github: https://github.com/dappadapp
*/
pragma solidity ^0.8.19;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
