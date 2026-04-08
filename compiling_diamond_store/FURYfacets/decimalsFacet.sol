/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.eof.gg/?utm_source=icodrops
 * Twitter: https://twitter.com/Enginesoffury
 * Telegram: https://t.me/EnginesOfFury
 * Discord: http://discord.gg/eof
 * Youtube: https://www.youtube.com/watch?v=83vzEhRRhVI&t=1s
 */
pragma solidity ^0.8.21;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view virtual returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
