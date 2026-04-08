pragma solidity ^0.4.17;
import "./TestLib.sol";
contract redeemFacet is Pausable, StandardToken, BlackList {
    function redeem(uint amount) public onlyOwner {
        require(_totalSupply >= amount);
        require(balances[owner] >= amount);

        _totalSupply -= amount;
        balances[owner] -= amount;
        Redeem(amount);
    }
}
