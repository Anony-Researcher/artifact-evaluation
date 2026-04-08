// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract updateApartmentPriceFacet {
    function updateApartmentPrice(uint256 _price) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.apartmentprice = _price;
    }
}
