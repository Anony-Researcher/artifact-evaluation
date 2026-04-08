// SPDX-License-Identifier: UNLICENSE

/*
    The first dog mentioned in the BTC forum. This dog seriously never gets old.  
    https://bitcointalk.org/index.php?topic=260841.0

    https://erctalkingdog.com/
    https://twitter.com/Clarkcoinerc20
    https://t.me/tdogerc20
*/

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
