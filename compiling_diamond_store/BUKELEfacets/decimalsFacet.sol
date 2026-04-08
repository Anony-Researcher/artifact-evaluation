// SPDX-License-Identifier: MIT

// $BUKELE
// Nayib Bukele, visionary leader, adopts Bitcoin, reforms prisons, and ensures safety.

// Website: bukele.xyz
// Telegram: t.me/bukele_eth
// x: x.com/ethbukele

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract decimalsFacet {
    using SafeMath for uint256;
    using Address for address payable;

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
