// File: Ownable.sol

/// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
import "./TestLib.sol";
contract balanceOfFacet is Ownable {
    using SafeMath for uint256;
    using SafeMathInt for int256;

    function balanceOf(address account) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._gonBalances[account].div(ds._gonsPerFragment);
    }
}
