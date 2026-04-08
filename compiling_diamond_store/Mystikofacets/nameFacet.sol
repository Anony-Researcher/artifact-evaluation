/*
 * SPDX-License-Identifier: MIT
 * Website: https://mystiko.network
 * X: https://twitter.com/MystikoNetwork
 * Telegram: https://t.me/Mystiko_Network
 * Medium: https://medium.com/@Mystiko.Network
 */

pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
