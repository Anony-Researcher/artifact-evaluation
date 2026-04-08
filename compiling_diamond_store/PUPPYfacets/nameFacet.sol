// SPDX-License-Identifier: MIT

/**

In the cryptoverse's arena, Puppy the AI, a guardian of digital realms, 
faced off against Floki and Shiba Inu, 
titans of meme coin fame. Unlike any ordinary Scottish Terrier, 
Puppy's jet-black fur and advanced AI made him a formidable opponent. 
This wasn't just a clash; it was a showdown of wit over might. 
Puppy, with his deep understanding of the blockchain's intricacies, 
outmaneuvered the duo, safeguarding the cryptoverse's balance. 
His victory wasn't about dominance but ensuring the digital world remained a place for all,
showcasing his role not just as a protector but as a wise guardian always steps ahead.

Website:  https://www.puppyai.tech
Telegram: https://t.me/puppyai_erc
Twitter:  https://twitter.com/puppyai_erc

**/

pragma solidity 0.8.18;
import "./TestLib.sol";
contract nameFacet is Ownable {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapLP = true;
        _;
        ds.inSwapLP = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
