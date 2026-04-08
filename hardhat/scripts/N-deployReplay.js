/* global ethers */
/* eslint prefer-const: "off" */
const { logtime } = require("./libraries/timelogger");

async function deployContract() {
  logtime();
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];

  const ctrct = await ethers.getContractFactory("MultiSig");
  const deployed = await ctrct.deploy([
    "0xFC82b3031d682DBf308A114f4FA09B5446AFcC94",
    "0xFC82b3031d682DBf308A114f4FA09B5446AFcC94",
  ]);
  await deployed.deployed();
  console.log("MultiSig deployed:", deployed.address);
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
