// SPDX-License-Identifier: UNLICENSE

/*

Name: Omega Cloud
Symbol: $OMEGA
Total Supply: 100,000,000
Decimals: 9

Omega Cloud | Unleashing Decentralized Power with Web3, GPU, and Revenue Sharing

Omega Cloud aims to address the growing demand for decentralized infrastructure and computational resources.

Unleash the Power of AI with Decentralized Physical Infrastructure Network: Comprehensive Services & Cutting-edge Innovations in our cloud applications - powered by a best-in-class AI infrastructure.

Future of decentralized computing 

- Web3 Infrastructure 
- GPU Computing
- Revenue Sharing
- Node/GPU Marketplace
-Server Hosting

Website: https://www.omegaclouderc.com/
Twitter: https://twitter.com/OmegaClouderc
Telegram: t.me/omegacloudportal
Docs: https://docs.omegaclouderc.com/
TG Bot:  t.me/OmegaERCBot

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
