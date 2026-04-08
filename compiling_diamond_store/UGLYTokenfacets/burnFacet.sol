// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract burnFacet {
    event Burn(address indexed from, uint256 value);
    event Transfer(address indexed from, address indexed to, uint256 value);
    function burn(uint256 _value) public returns (bool success) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.balanceOf[msg.sender] >= _value);
        ds.balanceOf[msg.sender] -= _value;
        ds.totalSupply -= _value;
        emit Burn(msg.sender, _value);
        emit Transfer(msg.sender, address(0), _value);
        return true;
    }
}
