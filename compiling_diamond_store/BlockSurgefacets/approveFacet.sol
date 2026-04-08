/*

    Telegram: https://t.me/BlockSurgePortal
    Website: https://blocksurge.net
    X: https://x.com/BlockSurge_ERC

**/

// SPDX-License-Identifier: unlicense

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract approveFacet {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    function approve(address spender, uint256 amount) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}
