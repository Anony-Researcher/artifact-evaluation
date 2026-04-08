/**
 */

// SPDX-License-Identifier: MIT
/*

TG: https://t.me/p1peai_erc
X: https://x.com/p1peai_erc20
Web: https://p1pe-ai.com/

**/

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
