/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.arcade2earn.io/
 * Discord: https://discord.com/invite/hhCm89Tsn7
 * Twitter: https://twitter.com/arcade2earn
 * Telegram: https://t.me/arcade2earn
 */
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
