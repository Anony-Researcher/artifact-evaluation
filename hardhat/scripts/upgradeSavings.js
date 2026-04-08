/* global describe it before ethers */

const {
    getSelectors,
    FacetCutAction,
    removeSelectors,
    findAddressPositionInFacets,
} = require("./libraries/diamond.js");

const { deployDiamond } = require("./deploy.js");
const { assert } = require('chai')
async function upgradeSavings() {
    const addresses = []
    let diamondAddress = "0xE128034D67d68fE5A72D8378A32ADcE24Cc68271";
    let diamondCutFacet;
    let diamondLoupeFacet;
    let ownershipFacet;

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

    //upgrade withdraw function
    const Test5Facet = await ethers.getContractFactory("reefix");
    const test5Facet = await Test5Facet.deploy();
    await test5Facet.deployed();
    addresses.push(test5Facet.address);
    const selectors_5 = getSelectors(test5Facet);
    tx = await diamondCutFacet.diamondCut(
        [
            {
                facetAddress: test5Facet.address,
                action: FacetCutAction.Replace,
                functionSelectors: selectors_5,
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
    console.log("Facet4 deployed", test5Facet.address);
    result = await diamondLoupeFacet.facetFunctionSelectors(test5Facet.address);
    assert.sameMembers(result, selectors_5)
    return;
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
    upgradeSavings()
        .then(() => process.exit(0))
        .catch((error) => {
            console.error(error);
            process.exit(1);
        });
}


exports.upgradeSavings = upgradeSavings
