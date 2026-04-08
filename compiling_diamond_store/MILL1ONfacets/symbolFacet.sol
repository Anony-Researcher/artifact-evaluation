/*
$MILL1ON
Sniff. Bark. Moonshot.
One in a Million Inu is not your regular backyard dig.
WEB     https://mill1on.vip
TG      https://t.me/OneinaMillionInu
X       https://twitter.com/MILL1ON_Inu
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
