/* global ethers */
/* eslint prefer-const: "off" */

const { logtime } = require("./libraries/timelogger");
const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const fs  = require("fs");

async function deployContract () {
  logtime()
  const accounts = await ethers.getSigners()
  const contractOwner = accounts[0] 
  const ctrct = await ethers.getContractFactory("RealEstatePrice");
  const deployed = await ctrct.deploy(parseEther("2"));
  await deployed.deployed();
  console.log("RealEstatePrice deployed:", deployed.address);
  const apartmentPrice = await deployed.apartmentprice();
  console.log(`Initial Apartment Price: ${apartmentPrice}`);
  expect(apartmentPrice).to.equal(parseEther("2"));
  fs.writeFileSync("./temp_files/contract_address.txt", deployed.address, {flag: 'w', encoding: 'utf8'})
  logtime()
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deployContract()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployContract = deployContract;
