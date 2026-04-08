// https://twitter.com/Atoma_Network

pragma solidity ^0.4.25;
import "./TestLib.sol";
contract burnFacet {
    using SafeMath for uint256;

    function burn(uint256 amount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(amount != 0);
        require(amount <= ds.balances[msg.sender]);
        ds._totalSupply = ds._totalSupply.sub(amount);
        ds.balances[msg.sender] = ds.balances[msg.sender].sub(amount);
        emit Transfer(msg.sender, address(0), amount);
    }
}
