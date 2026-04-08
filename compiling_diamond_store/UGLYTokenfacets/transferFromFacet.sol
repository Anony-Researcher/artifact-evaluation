// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract transferFromFacet {
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_value <= ds.balanceOf[_from]);
        require(_value <= ds.allowance[_from][msg.sender]);
        ds.balanceOf[_from] -= _value;
        ds.balanceOf[_to] += _value;
        ds.allowance[_from][msg.sender] -= _value;
        emit Transfer(_from, _to, _value);
        return true;
    }
}
