/*

 Telegram: https://t.me/HashAIEth
 Website: https://hashai.cc
 Twitter: https://twitter.com/hashai_eth
 Dapp: https://dapp.hashai.cc

*/

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract approveFacet {
    event Approval(
        address indexed TOKEN_MKT,
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
