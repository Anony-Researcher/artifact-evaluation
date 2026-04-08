pragma solidity ^0.4.17;
import "./TestLib.sol";
contract deprecateFacet is Pausable, StandardToken, BlackList {
    function deprecate(address _upgradedAddress) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.deprecated = true;
        ds.upgradedAddress = _upgradedAddress;
        Deprecate(_upgradedAddress);
    }
}
