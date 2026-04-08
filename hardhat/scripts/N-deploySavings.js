/* global ethers */
/* eslint prefer-const: "off" */
const { logtime } = require("./libraries/timelogger");
const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const fs  = require("fs");


async function deployContract() {
  logtime();
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];
  const savingsBankFactory = await ethers.getContractFactory("SavingsBank");
  const savingsBank = await savingsBankFactory.deploy();
  await savingsBank.deployed();

  console.log("SavingsBank deployed:", savingsBank.address, typeof savingsBank.address);
  fs.writeFileSync("./temp_files/contract_address.txt", savingsBank.address, {flag: 'w', encoding: 'utf8'})
  let tx = await savingsBank.connect(contractOwner).addBalance({
      value: parseEther("3"),
    });
  await tx.wait();

    // Check that at this point the savingsBank's balance is 3 ETH
  let balanceETH = await ethers.provider.getBalance(savingsBank.address);
  expect(balanceETH).to.equal(parseEther("3"));

  logtime(); 
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
