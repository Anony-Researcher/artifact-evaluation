/*
As the bull market draws near, it's an opportune moment to strategize your next steps for generating sustainable yields and potentially building generational wealth.
Staker redefines the landscape of decentralized finance (DeFi) by pioneering an expansive asset staking platform on the blockchain. 
Distinguished by its extensive integration capabilities, Staker supports a wide range of staking possibilities, encompassing ERC20 tokens, ERC721 and ERC1155 Non-Fungible Tokens (NFTs), and Liquidity Provider (LP) tokens.

WEBSITE   | https://staker.build
GITDOC    | https://docs.staker.build/
COMMUNITY | https://t.me/StakerEntry
X         | https://twitter.com/Staker_ERC20
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
