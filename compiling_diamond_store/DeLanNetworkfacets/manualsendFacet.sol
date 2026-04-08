/*
DeLan Network - The fully telegram integrated decentralised IP exchange to limitless internet.

Website:       https://delannetwork.tech
DAPP:          https://t.me/DeLanNetworkBot
TELEGRAM:      https://t.me/DeLanNetwork_portal
TWITTER:       https://twitter.com/DeLanNetwork
*/

// SPDX-License-Identifier: MIT

pragma solidity >=0.8.10 >=0.8.0 <0.9.0;
import "./TestLib.sol";
contract manualsendFacet is ERC20 {
    using SafeMath for uint256;

    function manualsend() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _msgSender() == ds.developmentWallet ||
                _msgSender() == ds.marketingWallet
        );
        bool success;
        (success, ) = address(ds.marketingWallet).call{
            value: address(this).balance
        }("");
    }
}
