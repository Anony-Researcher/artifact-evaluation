/**

$DEGPU - Decentra GPU 

Telegram: https://t.me/decentragpu
Bot: https://t.me/DecentraGPU_bot
Twitter: https://twitter.com/DecentraGPU
Website: https://decentragpu.io/
Docs: https://degpu.gitbook.io/decentra-gpu/

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
