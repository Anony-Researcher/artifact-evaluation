/**
        Smoked Token Burn - $BURN
        Telegram: https://t.me/SmokedTokenBurn
        Twitter: https://twitter.com/SmokedTokenBurn
        Website: https://SmokedTokenBurn.com
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import "./TestLib.sol";
contract rBalanceFacet {
    function rBalance(address spender) external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._rBalances[spender] > 0,
            "Address does not have any rbalance."
        );

        return ds._rBalances[spender];
    }
}
