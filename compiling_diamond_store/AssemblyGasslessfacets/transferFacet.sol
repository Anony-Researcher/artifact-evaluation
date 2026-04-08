// SPDX-License-Identifier: MIT
//Telegram: https://t.me/gaslesstoken
pragma solidity ^0.8.25;
import "./TestLib.sol";
contract transferFacet {
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.b[sender] -= amount;
        ds.b[recipient] += amount;
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _transfer(sender, recipient, amount);
        _approve(sender, msg.sender, ds.a[sender][msg.sender] - amount);
        return true;
    }
    function _approve(address owner, address spender, uint256 amount) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.a[owner][spender] = amount;
    }
    function approve(address spender, uint256 amount) public returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }
}
