// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
contract RealEstatePrice {
 uint256 public apartmentprice;

 constructor(uint256 _price) {
   apartmentprice = _price; // default
 }

 function getApartmentPrice() public view returns (uint256){
  return apartmentprice;
 }

 function updateApartmentPrice(uint256 _price) external {
   apartmentprice = _price;
 }
}