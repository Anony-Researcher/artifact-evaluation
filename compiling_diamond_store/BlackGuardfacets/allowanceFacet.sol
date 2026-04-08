// File: Ownable.sol

/// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
import "./TestLib.sol";
contract allowanceFacet is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    function allowance(
        address owner_,
        address spender
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowedFragments[owner_][spender];
    }
}
