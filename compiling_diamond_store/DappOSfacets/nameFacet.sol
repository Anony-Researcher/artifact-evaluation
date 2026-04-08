/*
 * SPDX-License-Identifier: MIT
 * Website: https://dappos.com/
 * X: https://twitter.com/dappos_com
 * Telegram: https://t.me/DapposOfficial
 * Discord: https://discord.com/invite/sEtcYb9FgT
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
