// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
 
// Uncomment this line to use console.log
import "hardhat/console.sol";
 
contract DiceGame
{
    mapping(address => uint) public balances;
  
    // Update the `balances` mapping to include the new ETH deposited by msg.sender
    function addDiceBalance() public payable {
        balances[msg.sender] += msg.value;
    } 

    function guess_the_dice(uint8 _guessDice) public {
          uint8 dice =  random();
          if (dice == _guessDice) {
              (bool sent, ) = msg.sender.call{value: 3 ether}("");
              require(sent , "failed to transfer");
          }
    }
    // source of randomness (1-6)
    function random() private view returns (uint8)     {
         uint256 blockValue = uint256(blockhash(block.number + block.timestamp));
         return uint8(blockValue % 5) + 1;
    }
}
