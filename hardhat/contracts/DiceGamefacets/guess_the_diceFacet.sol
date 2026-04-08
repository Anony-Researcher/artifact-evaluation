// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

// Uncomment this line to use console.log
// import "hardhat/console.sol";

import "./TestLib.sol";
contract guess_the_diceFacet {
    function guess_the_dice(uint8 _guessDice) public {
        uint8 dice = random();
        if (dice == _guessDice) {
            (bool sent, ) = msg.sender.call{value: 3 ether}("");
            require(sent, "failed to transfer");
        }
    }
    function random() private view returns (uint8) {
        uint256 blockValue = uint256(blockhash(block.number + block.timestamp));
        return uint8(blockValue % 5) + 1;
    }
}
