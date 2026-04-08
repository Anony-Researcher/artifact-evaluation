/*

VirtuOracle
Where virtual mastery meets predictive wisdom. 
VirtuOracle offers insightful analytics for the digital realm, 
guiding users through the complexities of cryptocurrency with precision and clarity.

TELEGRAM :  https://t.me/VirtuOracle
TWITTER : https://twitter.com/Virtuoracle
WEBSITE : https://virtuoracle.org/

*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
