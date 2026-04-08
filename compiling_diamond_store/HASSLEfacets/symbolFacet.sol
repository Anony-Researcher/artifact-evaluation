/**
https://hassle.cash
https://swap.hassle.cash
https://staking.hassle.cash
https://docs.hassle.cash

https://t.me/hassle_portal
https://twitter.com/hassle_cash
 */

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
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
