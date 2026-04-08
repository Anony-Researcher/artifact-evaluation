pragma solidity ^0.4.17;
import "./TestLib.sol";
contract totalSupplyFacet is Pausable, StandardToken, BlackList {
    function totalSupply() public constant returns (uint) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.deprecated) {
            return StandardToken(ds.upgradedAddress).totalSupply();
        } else {
            return _totalSupply;
        }
    }
}
