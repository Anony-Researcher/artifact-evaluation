// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
 
// Uncomment this line to use console.log
import "hardhat/console.sol";
 
contract Test1{
    constructor() payable{ }
 address[10] public owners;
    uint j= 100;
    uint i = 10+j;
 
    struct Checkpoint {
        uint256 timestamp;
        address payable amountt;
        uint256 amount;
    }
    string d = "KKKKK";
    mapping(address => uint) public balances;
    address[] public student_result;
    address payable payToThis;
    function guess_the_dice(uint8 _guessDice) public     {
        uint8 dice =  random();
        if (dice == _guessDice)           {
            (bool sent, ) = msg.sender.call{value: 1 ether}("");
            require(sent , "failed to transfer");
        }
    }
    // source of randomness (1-6)
    function random() private view returns (uint8)     {
        uint256 blockValue = uint256(blockhash(block.number-1 + block.timestamp));
        return uint8(blockValue % 5) + 1;
    }
    function getBalance() public view returns (uint) {
        return address(this).balance;
    }
}