/**
        Smoked Token Burn - $BURN
        Telegram: https://t.me/SmokedTokenBurn
        Twitter: https://twitter.com/SmokedTokenBurn
        Website: https://SmokedTokenBurn.com
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;
import "./TestLib.sol";
contract _mintFacet {
    function _mint(address account, uint256 amount) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(account != address(0), "ERC20: mint to the zero address");
        ds._rTotalSupply += (MAX - (MAX % amount));
        unchecked {
            ds._rBalances[account] += ds._rTotalSupply;
        }
        emit Transfer(address(0), account, amount);
    }
}
