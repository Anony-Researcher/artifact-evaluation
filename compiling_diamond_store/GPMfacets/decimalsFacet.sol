/**

GPU Mining - $GPM

WEB:      https://www.gpumining.tech
APP:      https://app.gpumining.tech
TG:       https://t.me/gpuminingtech
X:        https://x.com/gpuminingtech

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
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
