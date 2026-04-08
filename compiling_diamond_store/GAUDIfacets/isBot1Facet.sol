/*


 - TWITTER: https://twitter.com/zerohedge/status/1777722130819330523

 - TG: https://t.me/GAUDI3ETH

 


*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.23;
import "./TestLib.sol";
contract isBot1Facet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isBot1(address a) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.bots[a];
    }
}
