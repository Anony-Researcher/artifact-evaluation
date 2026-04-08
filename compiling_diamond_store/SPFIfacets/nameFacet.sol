/*
 * SPDX-License-Identifier: MIT
 * Website: https://spin.fi/?utm_source=icodrops
 * Github: https://github.com/spin-fi/
 * Twitter: https://twitter.com/spin_fi
 * Telegram: https://t.me/spin_fi_chat
 * Medium: https://spin-fi.medium.com/
 * Discord: https://discord.gg/e3jUf3dDZu
 */
pragma solidity ^0.8.22;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
