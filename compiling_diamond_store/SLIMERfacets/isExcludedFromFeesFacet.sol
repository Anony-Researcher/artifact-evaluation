// SPDX-License-Identifier: MIT

/* 
Generic taxable token with native currency and custom token recovery features.

Contract created by: Service Bridge https://serbridge.com/
SerBridge LinkTree with project updates https://linktr.ee/serbridge
*/

pragma solidity 0.8.17;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20, Ownable {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
