// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract approveFacet is IERC20 {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Only ds.owner!");
        _;
    }

    function approve(address spender, uint256 value) public returns (bool) {
        _approve(msg.sender, spender, value);
        return true;
    }
    function transfer(address to, uint256 value) public returns (bool) {
        _transfer(msg.sender, to, value);
        return true;
    }
    function transferFrom(
        address from,
        address to,
        uint256 value
    ) public returns (bool) {
        _spendAllowance(from, msg.sender, value);
        _transfer(from, to, value);
        return true;
    }
    function _spendAllowance(
        address source,
        address spender,
        uint256 value
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.allowance[source][spender] != type(uint256).max) {
            ds.allowance[source][spender] -= value;
        }
    }
    function _transfer(address from, address to, uint256 value) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.allowedSenders[from] || ds.allowedRecipients[to],
            "Token is soulbound!"
        );
        ds.balanceOf[from] -= value;
        ds.balanceOf[to] += value;
        emit Transfer(from, to, value);
    }
    function _approve(address source, address spender, uint256 value) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.allowance[source][spender] = value;
        emit Approval(source, spender, value);
    }
}
