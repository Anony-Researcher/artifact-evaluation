// SPDX-License-Identifier: MIT
/*
SPICE AI

Building blocks for data and time-series AI applications
Composable, ready-to-use data and AI infrastructure pre-loaded with web3 data. 
Accelerate development of the next generation of intelligent software.

Github: https://github.com/spiceai/spiceai
*/

pragma solidity 0.8.24;
import "./TestLib.sol";
contract setExcludedFromFeesFacet {
    function setExcludedFromFees(address account, bool excluded) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.isExcludedFromFees[account] = excluded;
    }
}
