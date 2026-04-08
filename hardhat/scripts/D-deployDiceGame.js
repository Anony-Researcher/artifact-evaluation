/* global describe it before ethers */

const {
    getSelectors,
    FacetCutAction,
    removeSelectors,
    findAddressPositionInFacets,
} = require("./libraries/diamond.js");

const { logtime } = require("./libraries/timelogger");
const { deployDiamond } = require("./deploy.js");
const { parseEther } = require("ethers/lib/utils");
const { assert } = require('chai')
const { expect } = require("chai");
const { ethers } = require("hardhat");
const fs  = require("fs");

async function deployDiceGame() {
    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];
    logtime();
    const addresses = []
    let diamondAddress;
    let diamondCutFacet;
    let diamondLoupeFacet;
    let ownershipFacet;
    diamondAddress = await deployDiamond();
    diamondCutFacet = await ethers.getContractAt(
        "DiamondCutFacet",
        diamondAddress
    );
    diamondLoupeFacet = await ethers.getContractAt(
        "DiamondLoupeFacet",
        diamondAddress
    );
    ownershipFacet = await ethers.getContractAt("OwnershipFacet", diamondAddress);

    for (const address of await diamondLoupeFacet.facetAddresses()) {
        addresses.push(address)
    }

    const Test2Facet = await ethers.getContractFactory("addDiceBalanceFacet");
    const test2Facet = await Test2Facet.deploy();
    await test2Facet.deployed();
    addresses.push(test2Facet.address);
    const selectors = getSelectors(test2Facet);
    tx = await diamondCutFacet.diamondCut(
        [
            {
                facetAddress: test2Facet.address,
                action: FacetCutAction.Add,
                functionSelectors: selectors,
            },
        ],
        ethers.constants.AddressZero,
        "0x",
        { gasLimit: 8000000 }
    );
    receipt = await tx.wait();
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`);
    }
    console.log("addBalance Facet deployed", test2Facet.address);
    result = await diamondLoupeFacet.facetFunctionSelectors(test2Facet.address);
    assert.sameMembers(result, selectors);

    const Test3Facet = await ethers.getContractFactory("guess_the_diceFacet");
    const test3Facet = await Test3Facet.deploy();
    await test3Facet.deployed();
    addresses.push(test3Facet.address);
    const selectors_2 = getSelectors(test3Facet);
    tx = await diamondCutFacet.diamondCut(
        [
            {
                facetAddress: test3Facet.address,
                action: FacetCutAction.Add,
                functionSelectors: selectors_2,
            },
        ],
        ethers.constants.AddressZero,
        "0x",
        { gasLimit: 8000000 }
    );
    receipt = await tx.wait();
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`);
    }
    console.log("guess_the_diceFacet deployed", test3Facet.address);
    result = await diamondLoupeFacet.facetFunctionSelectors(test3Facet.address);
    assert.sameMembers(result, selectors_2);

    fs.writeFileSync("./temp_files/contract_address.txt", diamondAddress, {flag: 'w', encoding: 'utf8'})
    const addDiceBalanceFacet = await ethers.getContractAt('addDiceBalanceFacet', diamondAddress); 
    tx = await addDiceBalanceFacet.connect(contractOwner).addDiceBalance({
        value: parseEther("3")
    });
    await tx.wait();

    balanceETH = await ethers.provider.getBalance(diamondAddress);
    console.log("Diamond Balance is ", balanceETH.toString());
    console.log("Diamond address is ", diamondAddress);

    expect(balanceETH).to.equal(parseEther("3"));
    logtime();
    return diamondAddress;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
    deployDiceGame()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
}


exports.deployDiceGame = deployDiceGame
