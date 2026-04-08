/*
RESHAPING FINANCIAL DYNAMICS WITH DEXACARD

WEBSITE        | https://dexacard.com
GITDOC         | https://docs.dexacard.com/
BOT            | https://t.me/DexaCardBot
TELEGRAM       | https://t.me/DexaCard_portal
TWITTER        | https://twitter.com/DexaCard
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
