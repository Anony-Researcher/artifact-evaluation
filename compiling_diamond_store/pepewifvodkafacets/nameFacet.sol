/**
PEPE got drunk on $VODKA, pour him some more so he doesn't sober up...


Tg: https://t.me/pepewifvodka
Web: https://pepewifvod.com
X: https://twitter.com/pepewifvodka
*/
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.24;
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
