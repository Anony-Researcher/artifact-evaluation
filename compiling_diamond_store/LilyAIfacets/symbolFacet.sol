//SPDX-License-Identifier: MIT

/**
Telegram: https://t.me/Lily_AI_Token
Twitter: https://twitter.com/LILYAI_ERC20
Website: https://lily-ai.tech/
Medium: https://medium.com/@lilyai.erc20
*/
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
