// SPDX-License-Identifier: MIT

// https://t.me/ChatGPUETH
// https://www.chatgpu.tech/
// https://twitter.com/Chat_GPU

pragma solidity 0.8.24;
import "./TestLib.sol";
contract isBotFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isBot(address a) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.bots[a];
    }
}
