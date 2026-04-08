// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20 {
    function totalSupply() public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.totalSupply_;
    }
    function balanceOf(
        address tokenOwner
    ) public view override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.balances[tokenOwner];
    }
    function transfer(
        address recipient,
        uint256 numTokens
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            numTokens <= ds.balances[msg.sender],
            "ERC20: transfer amount exceeds balance"
        );
        ds.balances[msg.sender] = ds.balances[msg.sender] - numTokens;
        ds.balances[recipient] = ds.balances[recipient] + numTokens;
        emit Transfer(msg.sender, recipient, numTokens);
        return true;
    }
    function approve(
        address spender,
        uint256 numTokens
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            numTokens == 0 || ds.allowed[msg.sender][spender] == 0,
            "ERC20: non-zero approve requires zero current allowance"
        );
        require(spender != address(0), "ERC20: approve to the zero address");
        ds.allowed[msg.sender][spender] = numTokens;
        emit Approval(msg.sender, spender, numTokens);
        return true;
    }
    function allowance(
        address owner,
        address delegate
    ) public view override returns (uint) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.allowed[owner][delegate];
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 numTokens
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(
            numTokens <= ds.balances[sender],
            "ERC20: transfer amount exceeds balance"
        );
        require(
            numTokens <= ds.allowed[sender][msg.sender],
            "ERC20: transfer amount exceeds allowance"
        );

        ds.balances[sender] = ds.balances[sender] - numTokens;
        ds.allowed[sender][msg.sender] =
            ds.allowed[sender][msg.sender] -
            numTokens;
        ds.balances[recipient] = ds.balances[recipient] + numTokens;
        emit Transfer(sender, recipient, numTokens);
        return true;
    }
}
