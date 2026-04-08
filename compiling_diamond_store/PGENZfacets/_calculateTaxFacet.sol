//// WE ARE NOT DEGENS!
/// WE ARE $PGENZ!

// PigeonPark.xyz
// http://t.me/PigeonPark
// twitter.com/pigeonparketh

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract _calculateTaxFacet {
    using SafeMath for uint256;

    function _calculateTax(uint256 amount) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 taxAmount = 0;
        uint256 calc = amount.mul(ds.buyTax).div(1000);
        taxAmount += calc;

        return taxAmount;
    }
}
