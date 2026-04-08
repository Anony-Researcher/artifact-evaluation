/*

    Tg: https://t.me/CxsTechnologies

    X: https://twitter.com/cxstechnologies

    Web: https://c-x-s.org
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract getSRewardTimeFacet is ERC20 {
    using SafeMath for uint256;

    function getSRewardTime(address user) external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.sRewardTime[user];
    }
}
