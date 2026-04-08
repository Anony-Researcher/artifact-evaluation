// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract transferFromFacet {
    event Transfer(address indexed from, address indexed to, uint256 value);
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 allowed = ds.allowance[from][msg.sender];

        if (allowed != type(uint256).max)
            ds.allowance[from][msg.sender] = allowed - amount;

        ds.balanceOf[from] -= amount;

        unchecked {
            ds.balanceOf[to] += amount;
        }

        emit Transfer(from, to, amount);

        return true;
    }
}
