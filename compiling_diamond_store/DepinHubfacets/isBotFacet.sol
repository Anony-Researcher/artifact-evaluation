// SPDX-License-Identifier: UNLICENSE

/*

DepinHub makes buying servers and VPNs easy. You use MetaMask to buy them with cryptocurrency. DepinHub has servers for AI tasks and private VPNs. It's global and adjusts to your needs. Once you pay, you get instant access. Stay updated with our newsletter. Join DepinHub for simple, secure server and VPN buying.

Join DepinHub today for a streamlined and reliable solution for acquiring servers and VPNs. With its user-friendly interface and commitment to privacy and security, DepinHub is the go-to platform for anyone looking to purchase infrastructure services with ease.

💲💲Benefits: 
➡️Convenience: Purchase servers and VPNs directly from our decentralized platform without the need for intermediaries.
➡️Security: Your transactions are secure and private thanks to MetaMask integration and blockchain technology.
➡️Instant Access: Get instant access to your server or VPN service as soon as the payment is confirmed.

TELEGRAM: https://t.me/Depinhubeth
TWITTER:https://twitter.com/HubDepin
WEBSITE: https://depinhub.shop/
DOCS: https://docs.depinhub.shop/
DApp: https://manage.depinhub.shop/

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
