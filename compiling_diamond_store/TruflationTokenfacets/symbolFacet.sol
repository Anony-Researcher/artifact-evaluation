/*
 * SPDX-License-Identifier: MIT
 * Website: https://truflation.com/
 * Telegram: https://t.me/truflation
 * Twitter: https://twitter.com/truflation
 */
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract symbolFacet {
    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenSymbol;
    }
}
