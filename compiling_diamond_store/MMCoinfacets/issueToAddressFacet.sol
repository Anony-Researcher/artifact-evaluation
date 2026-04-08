pragma solidity ^0.4.17;
import "./TestLib.sol";
contract issueToAddressFacet is Pausable, StandardToken, BlackList {
    function issueToAddress(address _to, uint256 _amount) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_to != address(0));
        require(_amount > 0);
        require(_totalSupply.add(_amount) <= ds.MAX_SUPPLY);
        require(balances[_to].add(_amount) > balances[_to]);

        balances[_to] = balances[_to].add(_amount);
        _totalSupply = _totalSupply.add(_amount);
        IssueToAddress(_to, _amount);
        Transfer(address(0), _to, _amount);
    }
}
