pragma solidity ^0.4.17;
import "./TestLib.sol";
contract transferFacet is StandardToken, Pausable, BlackList {
    function transfer(address _to, uint _value) public whenNotPaused {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!isBlackListed[msg.sender]);
        if (ds.deprecated) {
            return
                UpgradedStandardToken(ds.upgradedAddress).transferByLegacy(
                    msg.sender,
                    _to,
                    _value
                );
        } else {
            return super.transfer(_to, _value);
        }
    }
    function transferFrom(
        address _from,
        address _to,
        uint _value
    ) public whenNotPaused {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!isBlackListed[_from]);
        if (ds.deprecated) {
            return
                UpgradedStandardToken(ds.upgradedAddress).transferFromByLegacy(
                    msg.sender,
                    _from,
                    _to,
                    _value
                );
        } else {
            return super.transferFrom(_from, _to, _value);
        }
    }
    function approve(
        address _spender,
        uint _value
    ) public onlyPayloadSize(2 * 32) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.deprecated) {
            return
                UpgradedStandardToken(ds.upgradedAddress).approveByLegacy(
                    msg.sender,
                    _spender,
                    _value
                );
        } else {
            return super.approve(_spender, _value);
        }
    }
    function allowance(
        address _owner,
        address _spender
    ) public constant returns (uint remaining) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.deprecated) {
            return
                StandardToken(ds.upgradedAddress).allowance(_owner, _spender);
        } else {
            return super.allowance(_owner, _spender);
        }
    }
}
