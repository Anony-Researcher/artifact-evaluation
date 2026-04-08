/*  
   * SPDX-License-Identifier: MIT
    ▫️Website: https://www.aethir.com
    ▫️Twitter: https://twitter.com/AethirCloud
    ▫️Telegram: https://t.me/aethirofficial
    ▫️Discord: https://discord.gg/aethircloud
    ▫️Reddit: https://www.reddit.com/r/AethirCloud
    ▫️Linkedin: https://www.linkedin.com/company/aethir-limited
*/
pragma solidity ^0.8.17;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
