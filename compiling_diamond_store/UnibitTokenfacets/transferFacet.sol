// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract transferFacet {
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transfer(address to, uint256 amount) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.balanceOf[msg.sender] -= amount;

        unchecked {
            ds.balanceOf[to] += amount;
        }

        emit Transfer(msg.sender, to, amount);

        return true;
    }
}
