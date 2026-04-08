// File: Ownable.sol

/// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
import "./TestLib.sol";
contract isFeeExemptFacet is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    function isFeeExempt(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isFeeExempt[account];
    }
}
