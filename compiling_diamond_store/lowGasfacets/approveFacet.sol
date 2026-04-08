// SPDX-License-Identifier: MIT

// Telegram: https://t.me/lowgastoken
// Deploy TX: https://etherscan.io/tx/0xecb717e81b492fb2aaa63e3d2534395be5213bd33db084a3a7a18c68bc767599
// Runs (Optimizer) : 38
// EVM Version to target: Default

pragma solidity ^0.8.25;
import "./TestLib.sol";
contract approveFacet {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    function approve(address spender, uint amount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.z[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
    }
}
