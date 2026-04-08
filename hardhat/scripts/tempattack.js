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
let diceGame;
let attackerdice;

async function diceAttack() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];

  const Amount = ethers.utils.parseEther("4");
  const DiceGame = await ethers.getContractFactory("DiceGame");
  diceGame = await DiceGame.deploy();
  let tx = await diceGame.connect(contractOwner).addBalance({
        value: parseEther("3"),
    });
    await tx.wait();
  console.log(
    `DiceGame with ${ethers.utils.formatEther(
      Amount
    )}ETH deployed with address ${diceGame.address}`
  );

  const Attacker = await ethers.getContractFactory("AttackerDice");
  attackerdice = await Attacker.deploy(diceGame.address);

  console.log(
    `AttackerDice deployed with ${ethers.utils.formatEther(
      await attackerdice.getBalance())}`
  );

  await attackerdice.attack({gasLimit: 5000000,});
  console.log(
    `DiceGame has ${ethers.utils.formatEther(
      await diceGame.getBalance()
    )}ETH now`
  );
  console.log(
    `AttackerDice has ${ethers.utils.formatEther(
      await attackerdice.getBalance())} now`
  );

  await attackerdice.attack();
  console.log(
    `DiceGame has ${ethers.utils.formatEther(
      await diceGame.getBalance()
    )}ETH now`
  );
  console.log(
    `AttackerDice has ${ethers.utils.formatEther(
      await attackerdice.getBalance())} now`
  );

  await attackerdice.attack();
  console.log(
    `DiceGame has ${ethers.utils.formatEther(
      await diceGame.getBalance()
    )}ETH now`
  );
  console.log(
    `AttackerDice has ${ethers.utils.formatEther(
      await attackerdice.getBalance())} now`
  );

  await attackerdice.attack();
  console.log(
    `DiceGame has ${ethers.utils.formatEther(
      await diceGame.getBalance()
    )}ETH now`
  );
  console.log(
    `AttackerDice has ${ethers.utils.formatEther(
      await attackerdice.getBalance())} now`
  );

}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
diceAttack().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
exports.diceAttack = diceAttack;