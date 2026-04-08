// SPDX-License-Identifier: MIT
/**

Welcome to the future of computing with INOVAI - Innovation of Virtual Artificial Intelligence

Website         : https://inovai.network/
Whitepaper      : https://inovai.gitbook.io/inovai/
Github          : https://github.com/GitINOVAI
Telegram        : https://t.me/Inovai_Official
Twitter         : https://twitter.com/InovAI_Official

**/

pragma solidity 0.8.21;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
