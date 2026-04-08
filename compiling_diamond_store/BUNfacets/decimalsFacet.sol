/*
THE BIGGEST BUBBLE RUN - Ride the Bubble, But Don't Get Popped!

Welcome to The Biggest Bubble Run (BUN), the most exhilarating and entertaining ride through the wild world of market bubbles! Hold onto your seats as we embark on a journey to explore the biggest bubble in human history, filled with thrills, spills, and a whole lot of fun. But remember, while we're here to have a blast, we'll also keep a watchful eye on the risks that bubbles bring. Get ready for a crypto adventure like no other!

At BUN, we're all about turning the concept of market bubbles into a rollicking good time! We're not your typical crypto token; we're here for the sheer joy of it. Our mission? To bring laughter, memes, and a sense of camaraderie to the crypto community, all while playfully reminding you that bubbles can be both a chance and a risk. So hop on board, enjoy the ride, and let's make some unforgettable memories together. Bubbles, beware—BUN is here to show you how to have a blast while staying informed.

WEB | https://thebiggestbubblerun.co
TG  | https://t.me/BUN_Portal
X   | https://twitter.com/BUN_token
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
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
