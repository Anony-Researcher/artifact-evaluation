/*
 * SPDX-License-Identifier: MIT
 * Website: https://redstone.finance/
 * Whitepaper: https://docs.redstone.finance/docs/introduction
 * Twitter: https://twitter.com/redstone_defi
 * Telegram Group: https://t.me/redstonefinance/
 * Discord Chat: https://airdrops.io/visit/4hn2/
 */
pragma solidity ^0.8.22;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
