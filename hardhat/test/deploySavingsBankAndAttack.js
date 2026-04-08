const { logtime } = require("../scripts/libraries/timelogger");
const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

describe("Attack", function () {
  it("Should empty the balance of the good contract", async function () {
    // Deploy the good contract
    logtime();
    await new Promise(r => setTimeout(r, 10000));
    const savingsBankFactory = await ethers.getContractFactory("SavingsBank");
    const savingsBank = await savingsBankFactory.deploy();
    await savingsBank.deployed();
    console.log("Good contract deployed");


    await new Promise(r => setTimeout(r, 10000));
    //;Deploy the bad contract
    const attackerFactory = await ethers.getContractFactory("Attacker");
    const attacker = await attackerFactory.deploy(savingsBank.address);
    await attacker.deployed();
    console.log("Bad contract deployed");

    // Get two addresses, treat one as innocent user and one as attacker
    const [attackerAddress, innocentAddress] = await ethers.getSigners();
    console.log(innocentAddress.address);
    console.log(attackerAddress.address);
    // Innocent User deposits 3 ETH into savingsBank
    let tx = await savingsBank.connect(innocentAddress).addBalance({
      value: parseEther("3"),
    });
    await tx.wait();

    // Check that at this point the savingsBank's balance is 3 ETH
    let balanceETH = await ethers.provider.getBalance(savingsBank.address);
    expect(balanceETH).to.equal(parseEther("3"));

    // Attacker calls the `attack` function on attacker
    // and sends 1 ETH
    await new Promise(r => setTimeout(r, 10000));

    tx = await attacker.connect(attackerAddress).attack({
      value: parseEther("1"),
    });
    await tx.wait();

    console.log("Attack Executed");
    // Balance of the savingsBank's address is now zero
    balanceETH = await ethers.provider.getBalance(savingsBank.address);
    expect(balanceETH).to.equal(BigNumber.from("0"));

    // Balance of attacker is now 4 ETH (3 ETH stolen + 1 ETH from attacker)
    balanceETH = await ethers.provider.getBalance(attacker.address);
    expect(balanceETH).to.equal(parseEther("4"));
    logtime();
  });
});
