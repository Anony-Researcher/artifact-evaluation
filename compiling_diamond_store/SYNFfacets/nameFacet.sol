/*
 * SPDX-License-Identifier: MIT
 * Website: https://www.synfutures.com/
 * Whitepaper: https://www.synfutures.com/v3-whitepaper.pdf
 * Twitter: https://twitter.com/SynFuturesDefi
 * Telegram Group: https://t.me/synfutures_Defi
 * Discord Chat: https://discord.com/invite/qMX2kcQk7A
 * Medium: https://medium.com/synfutures
 */
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
