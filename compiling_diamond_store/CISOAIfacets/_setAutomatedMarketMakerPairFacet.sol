/**⠀⠀⠀⠀⠀⠀
https://www.anchain.ai/ciso

AnChain.AI understands complex cryptocurrency investigations and the time it takes to manually crawl transactions.  
Our AI-powered Auto-Trace feature allows the investigator to quickly establish a clear chain of custody from point 
of origin to multiple endpoints on the blockchain.
*/

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
import "./TestLib.sol";
contract _setAutomatedMarketMakerPairFacet is ERC20 {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    function _setAutomatedMarketMakerPair(address v2pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.automatedMarketMakerPairs[v2pair] = value;
    }
}
