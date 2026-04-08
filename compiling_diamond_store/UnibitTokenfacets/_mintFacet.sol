// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract _mintFacet {
    event Transfer(address indexed from, address indexed to, uint256 value);
    function _mint(address to, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.totalSupply += amount;

        unchecked {
            ds.balanceOf[to] += amount;
        }

        emit Transfer(address(0), to, amount);
    }
}
