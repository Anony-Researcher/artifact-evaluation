// SPDX-License-Identifier: Unlicensed

/*
Unleash the power of Blockchain AI with ChainGPT.

Website: https://chain-gpt.live
Telegram: https://t.me/chaingpt_ai_erc
Twitter: https://twitter.com/chaingpt_ai_erc
Dapp: https://app.chain-gpt.live
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isReEnterPrevented = true;
        _;
        ds._isReEnterPrevented = false;
    }

    function decimals() public view returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.decimals_;
    }
}
