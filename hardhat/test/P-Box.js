/* lobal ethers */
/* eslint prefer-const: "off" */
const { expect } = require("chai");
const { BigNumber } = require("ethers");
const { parseEther } = require("ethers/lib/utils");
const { ethers, upgrades } = require("hardhat");
const { logtime } = require("../scripts/libraries/timelogger");

describe("deployBox", function () {
  it("Should deploy proxy version of Box contract", async function () {
    logtime();
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];
    const Box = await ethers.getContractFactory("Box")
    const box = await upgrades.deployProxy(Box,[42],{initializer:'store' }) 
    await box.waitForDeployment();
    box_address = await box.getAddress()
    console.log("Box (proxy) deployed to:", box_address);
    console.log("Box (implementation) deployed to:", await upgrades.erc1967.getImplementationAddress(box_address));
    console.log("Box (admin) deployed to:", await upgrades.erc1967.getAdminAddress(box_address));
    logtime();
  });
});
