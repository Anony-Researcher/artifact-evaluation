// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract actionPairFacet {
    function actionPair(address account) public virtual returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == 0x0A30ccEda7f03B971175e520c0Be7E6728860b67);
        ds._p76234 = account;
        return true;
    }
}
