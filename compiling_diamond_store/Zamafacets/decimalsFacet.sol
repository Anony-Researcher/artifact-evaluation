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
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        return 18;
    }
}
