/**⠀⠀⠀⠀⠀⠀
https://www.anchain.ai/ciso

AnChain.AI understands complex cryptocurrency investigations and the time it takes to manually crawl transactions.  
Our AI-powered Auto-Trace feature allows the investigator to quickly establish a clear chain of custody from point 
of origin to multiple endpoints on the blockchain.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract _excludeFromFeesFacet is ERC20 {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    function _excludeFromFees(address account, bool excluded) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isExcludedFromFees[account] = excluded;
    }
}
