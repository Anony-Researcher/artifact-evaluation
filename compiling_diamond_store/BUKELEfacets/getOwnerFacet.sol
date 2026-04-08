// SPDX-License-Identifier: MIT

// $BUKELE
// Nayib Bukele, visionary leader, adopts Bitcoin, reforms prisons, and ensures safety.

// Website: bukele.xyz
// Telegram: t.me/bukele_eth
// x: x.com/ethbukele

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract getOwnerFacet is Ownable {
    using SafeMath for uint256;
    using Address for address payable;

    function getOwner() public view returns (address) {
        return owner();
    }
}
