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
