/* global describe it before ethers */

const {
    getSelectors,
    FacetCutAction,
    removeSelectors,
    findAddressPositionInFacets,
} = require("../scripts/libraries/diamond.js");

const { logtime } = require("./libraries/timelogger");
const { deployDiamond } = require("../scripts/deploy.js");
const { assert } = require('chai')
const { parseEther } = require("ethers/lib/utils");
const fs  = require("fs");

async function deployAuction() {
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

    const Test2Facet = await ethers.getContractFactory("bidFacet");
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
        { gasLimit: 800000 }
    );
    receipt = await tx.wait();
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`);
    }

    console.log("Facet1 deployed", test2Facet.address);
    result = await diamondLoupeFacet.facetFunctionSelectors(test2Facet.address);
    assert.sameMembers(result, selectors)   

    const Test4Facet = await ethers.getContractFactory("getHighestBidFacet");
    const test4Facet = await Test4Facet.deploy();
    await test4Facet.deployed();
    addresses.push(test4Facet.address);
    const selectors_4 = getSelectors(test4Facet);
    tx = await diamondCutFacet.diamondCut(
        [
            {
                facetAddress: test4Facet.address,
                action: FacetCutAction.Add,
                functionSelectors: selectors_4,
            },
        ],
        ethers.constants.AddressZero,
        "0x",
        { gasLimit: 800000 }
    );
    receipt = await tx.wait();
    if (!receipt.status) {
        throw Error(`Diamond upgrade failed: ${tx.hash}`);
    }
    console.log("Facet3 deployed", test4Facet.address);
    result = await diamondLoupeFacet.facetFunctionSelectors(test4Facet.address);
    assert.sameMembers(result, selectors_4) 

    const Auction = await ethers.getContractFactory("Auction");
    const auctionContract = Auction.attach(diamondAddress);

    const accounts = await ethers.getSigners();
    const contractOwner = accounts[0];

    tx = await auctionContract.connect(contractOwner).bid({
        value: parseEther("3"),
    });
    await tx.wait();

    fs.writeFileSync("./temp_files/contract_address.txt", diamondAddress, {flag: 'w', encoding: 'utf8'})
    logtime();
}

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
