/* global ethers */
/* eslint prefer-const: "off" */
const { logtime } = require("./libraries/timelogger");
const { expect } = require("chai");
const { ethers } = require("hardhat");
const fs = require("fs");

async function deployContract() {
  logtime();
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];
  
  const TrafficViolationDataFactory = await ethers.getContractFactory("TrafficViolationData");
  const trafficViolationData = await TrafficViolationDataFactory.deploy();
  await trafficViolationData.deployed();

  console.log("TrafficViolationData deployed:", trafficViolationData.address);

  // Save contract address to file
  fs.writeFileSync("./temp_files/contract_address.txt", trafficViolationData.address, { flag: 'w', encoding: 'utf8' });

  logtime();
}

async function storeViolation(contractAddress, imageHash, timestamp, location) {
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];

  const TrafficViolationData = await ethers.getContractAt("TrafficViolationData", contractAddress);
  await TrafficViolationData.connect(contractOwner).storeViolation(imageHash, timestamp, location);

  console.log("Violation stored:", { imageHash, timestamp, location });
}

async function getViolation(contractAddress, index) {
  const TrafficViolationData = await ethers.getContractAt("TrafficViolationData", contractAddress);
  let [storedImageHash, storedTimestamp, storedLocation] = await TrafficViolationData.getViolation(index);

  console.log("Violation retrieved:", { storedImageHash, storedTimestamp, storedLocation });

  return { storedImageHash, storedTimestamp, storedLocation };
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deployContract()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
}

exports.deployContract = deployContract;
exports.storeViolation = storeViolation;
exports.getViolation = getViolation;

