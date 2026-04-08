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

    const ctrct = await ethers.getContractFactory("DiceGame");
    const deployed = await ctrct.deploy();
    await deployed.deployed();
    console.log("DiceGame deployed:", deployed.address);
    fs.writeFileSync("./temp_files/contract_address.txt", deployed.address, {flag: 'w', encoding: 'utf8'})
    logtime();

    let tx = await deployed.connect(contractOwner).addDiceBalance({
        value: parseEther("3"),
    });
    await tx.wait();
  
    // Check that at this point the dice games's balance is 3 ETH
    let balanceETH = await ethers.provider.getBalance(deployed.address);
    expect(balanceETH).to.equal(parseEther("3"));
    console.log(`Balance of dice game is ${balanceETH}`);
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
