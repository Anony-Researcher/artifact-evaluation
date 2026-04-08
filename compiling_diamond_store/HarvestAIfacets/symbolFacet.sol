// SPDX-License-Identifier: MIT
/**
Earn HAI Coins with your PC, GPU & CPU

Leverage the power of your graphics card (GPU) and processor (CPU) to participate in the harvest process, contributing to the decentralized network and earning rewards in return.

Website:  https://www.harvestai.cloud
Telegram: https://t.me/HarvestAI_ERC
Twitter:  https://twitter.com/HarvestAI_ERC 
Dapp:     https://app.harvestai.cloud

**/
pragma solidity 0.8.19;
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
