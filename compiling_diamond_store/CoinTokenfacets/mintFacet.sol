// SPDX-License-Identifier: MIT

pragma solidity ^0.4.24;
import "./TestLib.sol";
contract mintFacet is PausableToken {
    event Mint(address indexed from, address indexed to, uint256 value);
    function mint(address account, uint256 amount) public onlyOwner {
        totalSupply = totalSupply.add(amount);
        balances[account] = balances[account].add(amount);
        emit Mint(address(0), account, amount);
        emit Transfer(address(0), account, amount);
    }
}
