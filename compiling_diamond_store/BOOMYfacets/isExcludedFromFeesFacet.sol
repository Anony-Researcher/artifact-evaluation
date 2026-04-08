// BOOMY = SONIC ???
// https://t.me/bommyeth

// SPDX-License-Identifier: MIT

pragma solidity =0.8.18;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20, Ownable {
    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
