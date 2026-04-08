/*

    Tg: https://t.me/CxsTechnologies

    X: https://twitter.com/cxstechnologies

    Web: https://c-x-s.org
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract updateSRewardTimeFacet is ERC20 {
    using SafeMath for uint256;

    function updateSRewardTime(address user, uint256 _newTime) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.ASICMineAddress, "Invalid caller");
        ds.sRewardTime[user] = _newTime;
    }
}
