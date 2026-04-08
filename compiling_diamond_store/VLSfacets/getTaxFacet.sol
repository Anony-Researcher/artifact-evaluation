// SPDX-License-Identifier: NONE

pragma solidity 0.8.19;
import "./TestLib.sol";
contract getTaxFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function getTax() public view returns (uint8 Buytax, uint8 Selltax) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (ds._BuyTax, ds._SellTax);
    }
}
