/* lobal ethers */
/* eslint prefer-const: "off" */
const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const { logtime } = require("../scripts/libraries/timelogger");

describe("deployBox", function () {
  it("Should deploy Savings Bank with a balance of 0.003 eth", async function () {
  logtime();
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];
  const savingsBankFactory = await ethers.getContractFactory("SavingsBank");
  const savingsBank = await savingsBankFactory.deploy();
  await savingsBank.deployed();

  console.log("SavingsBank deployed:", savingsBank.address, typeof savingsBank.address);
  let tx = await savingsBank.connect(contractOwner).addBalance({
      value: parseEther("0.003"),
    });
  await tx.wait();

    // Check that at this point the savingsBank's balance is 3 ETH
  let balanceETH = await ethers.provider.getBalance(savingsBank.address);
  expect(balanceETH).to.equal(parseEther("0.003"));
  logtime();
  });
});
