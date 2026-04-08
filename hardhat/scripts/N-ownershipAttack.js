// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.

const { logtime } = require("./libraries/timelogger");
const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const fs  = require("fs");

async function main() {
  logtime();
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[1];
  // console.log(accounts);

  const contractAddress = fs.readFileSync('./temp_files/contract_address.txt', 'utf8');
  console.log("Contract Address:", contractAddress);

  // Get the contract factory and attach to deployed address
  const RealEstatePrice = await ethers.getContractFactory("RealEstatePrice");
  const realEstatePrice = RealEstatePrice.attach(contractAddress);

  // Check the current apartment price
  const initialPrice = await realEstatePrice.apartmentprice();
  console.log("Initial Apartment Price:", ethers.utils.formatEther(initialPrice));

  // Attacker updates the price
  const newPrice = ethers.utils.parseEther("4");
  const tx = await realEstatePrice.connect(contractOwner).updateApartmentPrice(newPrice);
  await tx.wait(); // Wait for the transaction to be mined
  console.log("Apartment price updated by attacker.");

  // Check if the price actually got updated
  const updatedPrice = await realEstatePrice.apartmentprice();
  console.log("Updated Apartment Price:", ethers.utils.formatEther(updatedPrice));

  // Test: Verify the price got updated
  expect(updatedPrice).to.equal(newPrice);
  console.log("Price successfully updated to:", ethers.utils.formatEther(updatedPrice));

  logtime();
}
 
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});