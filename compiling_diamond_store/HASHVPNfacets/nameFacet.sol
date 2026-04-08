/*
WEB:  https://hashvpn.org
DOC:  https://docs.hashvpn.org/
BOT:  https://t.me/hashvpnBot
TG:   https://t.me/HashVPN_portal
TW:   https://twitter.com/HashVPN_erc20
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
