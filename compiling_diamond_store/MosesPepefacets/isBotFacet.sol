// SPDX-License-Identifier: UNLICENSE

/*
On November 17th, 2021, the creator of Pepe the Frog, Matt Furie, 
minted his first original Pepe GIF called "Moses Pepe" as an NFT on OpenSea, 
making it the first ever Pepe on Ethereum.

Telegram: https://t.me/mosespepetoken
Twitter: https://twitter.com/MosesPepeEth
Web: https://mosespepe.online/
*/

pragma solidity 0.8.23;
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
