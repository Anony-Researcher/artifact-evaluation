/* global ethers */
/* eslint prefer-const: "off" */
const { logtime } = require("./libraries/timelogger");

async function deployContract() {
    logtime();
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];

    const ctrct = await ethers.getContractFactory("InheritanceTest");
    const deployed = await ctrct.deploy();
    await deployed.deployed();
    console.log("InheritanceTest deployed:", deployed.address);
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