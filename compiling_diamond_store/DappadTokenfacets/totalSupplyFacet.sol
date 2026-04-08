/*  
   * SPDX-License-Identifier: MIT
    ▫️Website: https://dappad.app
    ▫️Twitter: https://twitter.com/Dappadofficial
    ▫️Discord: https://discord.gg/dappadlaunchpad
    ▫️Github: https://github.com/dappadapp
*/
pragma solidity ^0.8.19;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
