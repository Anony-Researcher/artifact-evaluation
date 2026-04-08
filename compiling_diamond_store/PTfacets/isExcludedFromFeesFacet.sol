/**
Twitter: https://twitter.com/PepetrumpOG
TG: https://t.me/pepetrumpethOG
**/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.13;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20, Ownable {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
