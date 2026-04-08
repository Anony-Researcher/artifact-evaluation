/**
Once upon a time, nestled in the lush canopies of the Amazon rainforest, lived Slerp the sloth, famed for his lethargic yet endearing ways.

Web: https://www.slerfpepe.xyz
X: https://x.com/SlerfPepe_ERC
Tg: https://t.me/slerfpepe_portal
**/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
