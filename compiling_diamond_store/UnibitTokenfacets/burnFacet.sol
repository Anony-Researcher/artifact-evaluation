// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract burnFacet {
    event Transfer(address indexed from, address indexed to, uint256 value);
    function burn(uint256 amount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.balanceOf[msg.sender] -= amount;

        unchecked {
            ds.totalSupply -= amount;
        }

        emit Transfer(msg.sender, address(0), amount);
    }
}
