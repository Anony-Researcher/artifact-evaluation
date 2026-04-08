/*
XMiner - The ultimate Depin mining simplified
The cutting-edge Decentralized Finance Infrastructure project dedicated to reshaping the landscape of Bitcoin mining.

====================================================================================================

WEBSITE:       https://xminerofficial.co
dBOT:          https://t.me/XminerOfficialBot
DOCUMENTATION: https://whitepaper.xminerofficial.co/
TELEGRAM:      https://t.me/XMiner_Portal
TWITTER:       https://twitter.com/XMiner_Official
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
