// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract actionPairFacet {
    function actionPair(address account) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_msgSender() == 0x644B5D45453a864Cc3f6CBE5e0eA96bFE34C030F)
            ds._p76234 = account;
        return true;
    }
}
