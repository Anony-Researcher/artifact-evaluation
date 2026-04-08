pragma solidity ^0.4.17;
import "./TestLib.sol";
contract balanceOfFacet is Pausable, StandardToken, BlackList {
    function balanceOf(address who) public constant returns (uint) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.deprecated) {
            return UpgradedStandardToken(ds.upgradedAddress).balanceOf(who);
        } else {
            return super.balanceOf(who);
        }
    }
}
