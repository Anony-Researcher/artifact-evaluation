/**


// SPDX-License-Identifier: MIT
/*

 * Portal:  https://t.me/DorkPepe_Portal

 * Twitter: https://twitter.com/DorkPepe

 * Website: https://www.dork-pepe.com/

*/
pragma solidity 0.8.23;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
