/*
 * SPDX-License-Identifier: MIT
 * Website: https://pac.finance/
 * Whitepaper: https://docs.pac.finance/
 * Twitter: https://twitter.com/pac_finance
 * Discord: https://discord.com/invite/PVvGxRMTDA
 */
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
