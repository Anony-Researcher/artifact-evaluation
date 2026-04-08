// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");

async function deployContract() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];
    const Box = await ethers.getContractFactory("Box");
    const box = await Box.deploy();
    await box.waitForDeployment();
}

if (require.main === module) {
    deployContract()
      .then(() => process.exit(0))
      .catch((error) => {
        console.error(error);
        process.exit(1);
      });
  }
