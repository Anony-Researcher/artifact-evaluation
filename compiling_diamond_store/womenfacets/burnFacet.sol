/**
 *Submitted for verification at EtherScan.com on 2021-06-20
 */

/**
 *
 *
   https://WomensRights.xyz
   https://x.com/womensrightseth
   https://t.me/WomensRightsDAO
   

   Contract features:
   69,000,420 tokens
   3% buy tax in ETH sent to marketing, community & dev
   16% sell tax in ETH sent to marketing, community & dev
 */

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;
import "./TestLib.sol";
contract burnFacet is ERC20 {
    using SafeMath for uint256;

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
