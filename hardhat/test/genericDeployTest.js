/* global describe it before ethers */

const { getSelectors, FacetCutAction } = require("../scripts/libraries/diamond.js");
const { deployDiamond } = require("../scripts/deploy.js");
const { deployFacetsFromFolder } = require("../scripts/genericDeploy.js");
const { assert } = require('chai');
const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");

describe('Diamond Deployment and Facet Integration', function () {
    let diamond;
    let diamondCutFacet;
    let diamondLoupeFacet;
    let ownershipFacet;
    let contractOwner;
    let totalGasUsed;

    const facetsFolderPath = "../contracts/Aierifyfacets";


    before(async function () {
        const accounts = await ethers.getSigners();
        contractOwner = accounts[0];

        // Deploy the Diamond
        diamond = await deployDiamond();
        const diamondDeploymentReceipt = await diamond.deployTransaction.wait();
        totalGasUsed = ethers.BigNumber.from(diamondDeploymentReceipt.gasUsed);
        console.log("Diamond contract deployed at:", diamond.address);
        console.log("Gas used for deploying Diamond:", diamondDeploymentReceipt.gasUsed.toString());

        // Get facet instances
        diamondCutFacet = await ethers.getContractAt("DiamondCutFacet", diamond.address);
        diamondLoupeFacet = await ethers.getContractAt("DiamondLoupeFacet", diamond.address);
        ownershipFacet = await ethers.getContractAt("OwnershipFacet", diamond.address);
    });

    it('should deploy facets from folder and add them to the diamond', async function () {
        assert(diamond.address, "Diamond address should be defined");

        // Deploy facets from the specified folder and add them to the diamond
        totalGasUsed = await deployFacetsFromFolder(facetsFolderPath, diamondCutFacet, totalGasUsed, contractOwner);
        
        // Check that facets have been added to the diamond
        const facetAddresses = await diamondLoupeFacet.facetAddresses();
        assert(facetAddresses.length > 0, "Facets should have been added to the diamond");
        console.log("Facet addresses:", facetAddresses);

        // Log total gas used
        console.log("Total gas used during deployment:", totalGasUsed.toString());
    });

    it('should verify ownership facet is set correctly', async function () {
        const owner = await ownershipFacet.owner();
        assert.equal(owner, contractOwner.address, "Contract owner should be correctly set in OwnershipFacet");
    });
});
