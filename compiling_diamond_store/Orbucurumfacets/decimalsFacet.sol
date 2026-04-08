/*
THE FUTURE OF MARKET INTELLIGENCE
WEBSITE:  https://orbucurum.com
TELEGRAM: https://t.me/Orbucurum_portal
TWITTER:  https://twitter.com/Orbucurum_erc
DOC:      https://docs.orbucurum.com/
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
