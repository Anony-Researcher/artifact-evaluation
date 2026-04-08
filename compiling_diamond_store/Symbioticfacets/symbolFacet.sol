/**
 *
 */

/*

https://www.symbotic.com/
Powered by A.I.
A.I.-powered software seamlessly orchestrates hundreds of industrial robots within the system. 
The comprehensive proprietary artificial intelligence software manages the entire end-to-end system from case
digitization and complex bot routing to sequencing, planning and building the perfect mixed-SKU pallet.
*/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
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
