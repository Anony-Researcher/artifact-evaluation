/* global describe it before ethers */

const {
    getSelectors,
    FacetCutAction,
    removeSelectors,
    findAddressPositionInFacets,
} = require("../scripts/libraries/diamond.js");

const { expect, assert } = require("chai");
const hre = require("hardhat");
const { deployDiamond } = require("../scripts/deploy.js");

describe("Deployment", function () {

    before(async function () {
    const addresses = []
    let diamondAddress;
    let diamondCutFacet;
    let diamondLoupeFacet;
    let ownershipFacet;
    const diamond = await deployDiamond();
    diamondAddress = diamond.address;
    diamondCutFacet = await ethers.getContractAt(
        "DiamondCutFacet",
        diamondAddress
    );
    diamondLoupeFacet = await ethers.getContractAt(
        "DiamondLoupeFacet",
        diamondAddress
    );
    ownershipFacet = await ethers.getContractAt("OwnershipFacet", diamondAddress);

    // for (const address of await diamondLoupeFacet.facetAddresses()) {
    //     addresses.push(address)
    // }

    // const Test2Facet = await ethers.getContractFactory("depositFacet");
    // const test2Facet = await Test2Facet.deploy();
    // await test2Facet.deployed();
    // addresses.push(test2Facet.address);
    // const selectors = getSelectors(test2Facet);
    // tx = await diamondCutFacet.diamondCut(
    //     [
    //         {
    //             facetAddress: test2Facet.address,
    //             action: FacetCutAction.Add,
    //             functionSelectors: selectors,
    //         },
    //     ],
    //     ethers.constants.AddressZero,
    //     "0x",
    //     { gasLimit: 800000 }
    // );
    // receipt = await tx.wait();
    // if (!receipt.status) {
    //     throw Error(`Diamond upgrade failed: ${tx.hash}`);
    // }
    // console.log("Facet1 deployed", test2Facet.address);
    // result = await diamondLoupeFacet.facetFunctionSelectors(test2Facet.address);
    // assert.sameMembers(result, selectors)

    // const Test3Facet = await ethers.getContractFactory("getBalanceFacet");
    // const test3Facet = await Test3Facet.deploy();
    // await test3Facet.deployed();
    // addresses.push(test3Facet.address);
    // const selectors_3 = getSelectors(test3Facet);
    // tx = await diamondCutFacet.diamondCut(
    //     [
    //         {
    //             facetAddress: test3Facet.address,
    //             action: FacetCutAction.Add,
    //             functionSelectors: selectors_3,
    //         },
    //     ],
    //     ethers.constants.AddressZero,
    //     "0x",
    //     { gasLimit: 800000 }
    // );
    // receipt = await tx.wait();
    // if (!receipt.status) {
    //     throw Error(`Diamond upgrade failed: ${tx.hash}`);
    // }
    // console.log("Facet2 deployed", test3Facet.address);
    // result = await diamondLoupeFacet.facetFunctionSelectors(test3Facet.address);
    // assert.sameMembers(result, selectors_3)   

    // const Test4Facet = await ethers.getContractFactory("withdrawFacet");
    // const test4Facet = await Test4Facet.deploy();
    // await test4Facet.deployed();
    // addresses.push(test4Facet.address);
    // const selectors_4 = getSelectors(test4Facet);
    // tx = await diamondCutFacet.diamondCut(
    //     [
    //         {
    //             facetAddress: test4Facet.address,
    //             action: FacetCutAction.Add,
    //             functionSelectors: selectors_4,
    //         },
    //     ],
    //     ethers.constants.AddressZero,
    //     "0x",
    //     { gasLimit: 800000 }
    // );
    // receipt = await tx.wait();
    // if (!receipt.status) {
    //     throw Error(`Diamond upgrade failed: ${tx.hash}`);
    // }
    // console.log("Facet3 deployed", test4Facet.address);
    // result = await diamondLoupeFacet.facetFunctionSelectors(test4Facet.address);
    // assert.sameMembers(result, selectors_4)   

    // //upgrade withdraw function
    // // const Test5Facet = await ethers.getContractFactory("reefix");
    // // const test5Facet = await Test5Facet.deploy();
    // // await test5Facet.deployed();
    // // addresses.push(test5Facet.address);
    // // const selectors_5 = getSelectors(test5Facet);
    // // tx = await diamondCutFacet.diamondCut(
    // //     [
    // //         {
    // //             facetAddress: test5Facet.address,
    // //             action: FacetCutAction.Replace,
    // //             functionSelectors: selectors_5,
    // //         },
    // //     ],
    // //     ethers.constants.AddressZero,
    // //     "0x",
    // //     { gasLimit: 800000 }
    // // );
    // // receipt = await tx.wait();
    // // if (!receipt.status) {
    // //     throw Error(`Diamond upgrade failed: ${tx.hash}`);
    // // }
    // // console.log("Facet4 deployed", test5Facet.address);
    // // result = await diamondLoupeFacet.facetFunctionSelectors(test5Facet.address);
    // // assert.sameMembers(result, selectors_5)




    
    return diamondAddress;
    })
})

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
    deployAuction()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
}


exports.deployAuction = deployAuction
