// SPDX-License-Identifier: UNLICENSE

/*
STECH AI

A new innovative product STech Al which allows businesses in any field to optimize and simplify the task of 
online support on the website.
STech AI model voice assistant provides users with extensive customizability options which allows the adjustment of 
the voice assistant configuration to suit both personal and professional requirements.

Our product is Conversational AI for individual assistance to clients, a personal assistant and consultant on the website,
quickly learns individually for your product and understands the specifics of your business, based on this it issues an 
individual solution for each client. A huge advantage of our product is that it allows you to simultaneously handle 
conversations with more than 1000 clients via chat, which a human cannot do.

https://www.stechai.io

https://t.me/StechAi

https://twitter.com/StechAI_ETH

https://docs.stechai.io/


*/

pragma solidity ^0.8.18;
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
