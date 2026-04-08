/* global ethers */
/* eslint prefer-const: "off" */
const { logtime } = require("./libraries/timelogger");
const { expect } = require("chai");
const { parseEther } = require("ethers/lib/utils");
const fs = require("fs");

async function deployContract() {
  logtime();
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];

  // Deploy SavingsBank contract
  const savingsBankFactory = await ethers.getContractFactory("SavingsBank");
  const savingsBank = await savingsBankFactory.deploy();

  // Wait for the contract deployment to complete
  const receipt = await savingsBank.deployTransaction.wait();
  console.log("SavingsBank deployed at:", savingsBank.address, "Block Number:", receipt.blockNumber);

  // Write contract address to file
  fs.writeFileSync("./temp_files/contract_address.txt", savingsBank.address, { flag: 'w', encoding: 'utf8' });

  // Interact with the deployed contract: Add 3 ETH to the balance
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

