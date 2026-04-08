pragma solidity ^0.4.17;
import "./TestLib.sol";
contract issueFacet is Pausable, StandardToken, BlackList {
    function issue(uint amount) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_totalSupply + amount <= ds.MAX_SUPPLY);
        require(_totalSupply + amount > _totalSupply);
        require(balances[owner] + amount > balances[owner]);

        balances[owner] += amount;
        _totalSupply += amount;
        Issue(amount);
    }
}
