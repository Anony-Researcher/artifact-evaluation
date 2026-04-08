const {
    getSelectors,
    FacetCutAction,
    removeSelectors,
    findAddressPositionInFacets,
  } = require("./libraries/diamond.js");
  
  const { deployDiamond } = require("./deploy.js");
  const { parseEther } = require("ethers/lib/utils");
  const { assert } = require('chai')
  const { expect } = require("chai");
  const { ethers } = require("hardhat");
  const fs = require("fs").promises; // Using promises for async/await
  
  async function deployDiamondContract(facetDirectory) {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];
  
    const diamondAddress = await deployDiamond();
    const diamondCutFacet = await ethers.getContractAt(
      "DiamondCutFacet",
      diamondAddress
    );
    const diamondLoupeFacet = await ethers.getContractAt(
      "DiamondLoupeFacet",
      diamondAddress
    );
    const ownershipFacet = await ethers.getContractAt("OwnershipFacet", diamondAddress);
  
    const deployedFacets = await getDeployedFacets(facetDirectory); // New function
  
    for (const deployedFacet of deployedFacets) {
      const selectors = getSelectors(deployedFacet);
      const tx = await diamondCutFacet.diamondCut(
        [
          {
            facetAddress: deployedFacet.address,
            action: FacetCutAction.Add,
            functionSelectors: selectors,
          },
        ],
        ethers.constants.AddressZero,
        "0x",
        { gasLimit: 8000000 }
      );
      const receipt = await tx.wait();
      if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`);
      }
      console.log(`${deployedFacet.name} Facet deployed`, deployedFacet.address);
      const result = await diamondLoupeFacet.facetFunctionSelectors(deployedFacet.address);
      assert.sameMembers(result, selectors);
    }
  
    // Rest of the code remains the same (interacting with addDiceBalanceFacet etc.)
  
    return diamondAddress;
  }
  
  async function getDeployedFacets(directory) {
    const files = await fs.readdir(directory);
    const deployedFacets = [];
    for (const file of files) {
      if (file.endsWith(".sol")) {
        const artifact = await ethers.getContractFactory(
          `${directory}/${file.slice(0, -4)}`
        ); // Use fully qualified name for TestLib
        const deployedFacet = await artifact.deploy();
        await deployedFacet.deployed();
        deployedFacets.push({ name: file.slice(0, -4), address: deployedFacet.address });
      }
    }
    return deployedFacets;
  }
  
  // Main function with argument handling
  if (process.argv.length !== 3) {
    console.error("Usage: node deployment_script.js <facetDirectory>");
    process.exit(1);
  }
  
  const facetDirectory = process.argv[2];
  
  deployDiamondContract(facetDirectory)
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
  
  exports.deployDiamondContract = deployDiamondContract;  