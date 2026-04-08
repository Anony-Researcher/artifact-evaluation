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
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
