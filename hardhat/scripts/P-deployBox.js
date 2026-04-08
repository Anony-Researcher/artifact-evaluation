// scripts/create-box.js
const { ethers, upgrades } = require("hardhat");

async function deployContract() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];
    const Box = await ethers.getContractFactory("Box")
    const box = await upgrades.deployProxy(Box,[42],{initializer:'store' }) 
    await box.waitForDeployment();
    console.log(box.gasUsed);
    box_address = await box.getAddress()
    console.log("Box (proxy) deployed to:", box_address);
    console.log("Box (implementation) deployed to:", await upgrades.erc1967.getImplementationAddress(box_address));
    console.log("Box (admin) deployed to:", await upgrades.erc1967.getAdminAddress(box_address));
}

if (require.main === module) {
    deployContract()
      .then(() => process.exit(0))
      .catch((error) => {
        console.error(error);
        process.exit(1);
      });
  }
