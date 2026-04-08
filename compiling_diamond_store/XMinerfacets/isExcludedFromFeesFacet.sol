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
contract isExcludedFromFeesFacet is ERC20 {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
