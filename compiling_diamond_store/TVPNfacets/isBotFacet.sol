// SPDX-License-Identifier: UNLICENSE

/*

TensorVPN: For Secure Connections Without Boundaries

TensorVPN revolutionizes the VPN experience with decentralized applications (dApps) and a Telegram bot for seamless, private VPN purchases.

DAPP
TensorVPN incorporates decentralized application (dApp) integration, leveraging blockchain technology to offer secure and private VPN services. Users can seamlessly purchase and manage VPN subscriptions through decentralized applications, ensuring heightened privacy and security for their online activities. By utilizing decentralized infrastructure, TensorVPN enhances user trust and transparency while maintaining anonymity.

Telegram Bot
TensorVPN streamlines the VPN subscription process with Telegram bot integration, allowing users to effortlessly purchase VPN services directly through the messaging platform. This feature eliminates the need for traditional login procedures, providing a convenient and user-friendly experience.

Telegram: https://t.me/TensorVPN
Twitter: https://twitter.com/TensorVPN
Website: https://tensorvpn.net
Bot: https://t.me/tensorvpnbot
DApp: https://store.tensorvpn.net
Docs: https://docs.tensorvpn.net

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
