/*
 * SPDX-License-Identifier: MIT
 * Website: https://exv.io/
 * Telegram: https://t.me/exverse
 * Twitter: https://twitter.com/exverse_io
 */
pragma solidity ^0.8.22;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
