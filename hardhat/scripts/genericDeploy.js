/* global describe it before ethers */

const {
    getSelectors,
    FacetCutAction,
} = require("./libraries/diamond.js");

const { logtime } = require("./libraries/timelogger");
const { deployDiamond } = require("./deployCalc.js");
const { assert } = require('chai');
const { ethers } = require("hardhat");
const fs = require("fs");
const path = require("path");

// Function to calculate statistical metrics
function calculateStatistics(gasUsages) {
    if (gasUsages.length === 0) {
        return {
            min: 0,
            max: 0,
            average: 0,
            stdev: 0
        };
    }

    const min = Math.min(...gasUsages);
    const max = Math.max(...gasUsages);
    const sum = gasUsages.reduce((acc, val) => acc + val, 0);
    const average = sum / gasUsages.length;

    const variance = gasUsages.reduce((acc, val) => acc + Math.pow(val - average, 2), 0) / gasUsages.length;
    const stdev = Math.sqrt(variance);

    return {
        min,
        max,
        average,
        stdev
    };
}

async function deployFacetsFromFolder(folderPath, diamondCutFacet, contractOwner) {
    const facets = fs.readdirSync(folderPath);
    console.log("\nDeploying Facets from folder\n");

    // Array to store gas usage for each facet
    const gasUsages = [];
    let totalGasFacets = 0; // Initialize total gas used for all facets

    for (const file of facets) {
        if (path.extname(file) === '.sol' && file !== 'TestLib.sol') {
            const filePath = path.join(folderPath, file);
            const contractName = file.split(".")[0];
            // Constructing the fully qualified name
            const fullyQualifiedName = `contracts/${path.basename(folderPath)}/${file}:${contractName}`;
            console.log(`Deploying ${fullyQualifiedName} from ${filePath}...`);
            let gasUsedCut = 0;
            try {
                // Deploy the facet
                const facetFactory = await ethers.getContractFactory(fullyQualifiedName);
                const facetInstance = await facetFactory.deploy();
                await facetInstance.deployed();
                const receiptDeploy = await facetInstance.deployTransaction.wait();
                const gasUsedDeploy = receiptDeploy.gasUsed.toNumber();
                console.log(`${contractName} deployed: ${facetInstance.address}`);
                console.log(`Gas Used for Deployment: ${gasUsedDeploy}`);
                
                try {
                    // Add the facet to the diamond
                    const selectors = getSelectors(facetInstance);
                    const tx = await diamondCutFacet.connect(contractOwner).diamondCut(
                        [{
                            facetAddress: facetInstance.address,
                            action: FacetCutAction.Add,
                            functionSelectors: selectors,
                        }],
                        ethers.constants.AddressZero,
                        "0x",
                        { gasLimit: 8000000 }
                    );
                    const receiptCut = await tx.wait();
                    gasUsedCut = receiptCut.gasUsed.toNumber();
                    console.log(`${contractName} added to diamond. Transaction hash: ${tx.hash}`);
                } catch (error) {
                    console.log("Selector Already Exists!");
                }

                console.log(`Gas Used for Diamond Cut: ${gasUsedCut}`);

                // Total gas used for this facet
                const totalGasUsedFacet = gasUsedDeploy + gasUsedCut;
                gasUsages.push(totalGasUsedFacet);
                totalGasFacets += totalGasUsedFacet;
                console.log(`Total Gas Used for ${contractName}: ${totalGasUsedFacet}\n`);
            } catch (error) {
                console.error(`Failed to deploy ${fullyQualifiedName}:`, error);
            }
        }
    }

    // Calculate statistics
    const stats = calculateStatistics(gasUsages);

    // Print statistics
    console.log("=== Gas Usage Statistics for Facet Deployments ===");
    console.log(`Number of Facets Deployed: ${gasUsages.length}`);
    console.log(`Minimum Gas Used: ${stats.min}`);
    console.log(`Maximum Gas Used: ${stats.max}`);
    console.log(`Average Gas Used: ${stats.average.toFixed(2)}`);
    console.log(`Standard Deviation: ${stats.stdev.toFixed(2)}`);
    console.log(`Total Gas Used for Facets: ${totalGasFacets}`);
    console.log("==================================================\n");

    return { stats, totalGasFacets };
}


async function deployDiamondWithFacets(facetsFolderPath) {
    let totalGasUsed = ethers.BigNumber.from(0);
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];

    logtime();

    let diamondAddress;
    let diamondCutFacet;
    let diamondLoupeFacet;
    let ownershipFacet;

    // Deploy the Diamond contract
    const { diamond, totalGasUsed: diamondDeployGas } = await deployDiamond();
    diamondAddress = diamond.address;

    totalGasUsed = totalGasUsed.add(diamondDeployGas);

    console.log("Diamond contract deployed at:", diamondAddress);
    console.log("Gas Used to Deploy Diamond: ", diamondDeployGas.toString());
    console.log("Total Gas Used Till Now: ", totalGasUsed.toString());

    // Connect to Diamond Facets
    diamondCutFacet = await ethers.getContractAt(
        "DiamondCutFacet",
        diamondAddress
    );
    diamondLoupeFacet = await ethers.getContractAt(
        "DiamondLoupeFacet",
        diamondAddress
    );
    ownershipFacet = await ethers.getContractAt("OwnershipFacet", diamondAddress);

    // Retrieve existing facet addresses (optional, can be used for verification)
    const existingFacetAddresses = await diamondLoupeFacet.facetAddresses();
    // You can perform operations with existingFacetAddresses if needed

    // Deploy additional facets from the folder and get gas statistics
    const { stats: gasStats, totalGasFacets } = await deployFacetsFromFolder(facetsFolderPath, diamondCutFacet, contractOwner);

    // Accumulate total gas used
    totalGasUsed = totalGasUsed.add(ethers.BigNumber.from(totalGasFacets));

    console.log("Total gas used during deployment:", totalGasUsed.toString());

    logtime();
    return { diamondAddress, gasStats, totalGasUsed };
}

module.exports = { deployDiamondWithFacets };

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
    // You can modify this path as needed or make it configurable via environment variables or arguments
    const facetsFolder = path.resolve(__dirname, "../contracts/Aierifyfacets");
    if (!facetsFolder) {
        console.error("Please provide the path to the folder containing the facets.");
        process.exit(1);
    }

    deployDiamondWithFacets(facetsFolder)
        .then(({ diamondAddress, gasStats, totalGasUsed }) => {
            console.log("=== Final Deployment Summary ===");
            console.log("Diamond contract deployed at:", diamondAddress);
            console.log("Gas Usage Statistics per Facet:");
            console.log(`- Minimum Gas Used: ${gasStats.min}`);
            console.log(`- Maximum Gas Used: ${gasStats.max}`);
            console.log(`- Average Gas Used: ${gasStats.average.toFixed(2)}`);
            console.log(`- Standard Deviation: ${gasStats.stdev.toFixed(2)}`);
            console.log(`- Total Gas Used for Facets: ${gasStats.sum || gasStats.totalGasFacets}`); // Adjusted to show correct total
            console.log(`Total gas used during deployment: ${totalGasUsed.toString()}`);
            console.log("=================================\n");
            process.exit(0);
        })
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
}

exports.deployDiamondWithFacets = deployDiamondWithFacets;