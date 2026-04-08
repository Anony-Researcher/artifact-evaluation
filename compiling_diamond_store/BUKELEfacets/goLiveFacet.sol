// SPDX-License-Identifier: MIT

// $BUKELE
// Nayib Bukele, visionary leader, adopts Bitcoin, reforms prisons, and ensures safety.

// Website: bukele.xyz
// Telegram: t.me/bukele_eth
// x: x.com/ethbukele

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract goLiveFacet {
    using SafeMath for uint256;
    using Address for address payable;

    function goLive() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._Launch = true;
        ds._transfersEnabled = true;
    }
}
