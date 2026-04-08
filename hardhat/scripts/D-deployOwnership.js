/* global ethers */
/* eslint prefer-const: "off" */

const { getSelectors, FacetCutAction } = require('./libraries/diamond.js')
const { assert } = require('chai')
const { logtime } = require("./libraries/timelogger");
const fs  = require("fs");

async function deployDiamond () {
  const accounts = await ethers.getSigners()
  const contractOwner = accounts[0]

  logtime();

  // Deploy DiamondInit
  // DiamondInit provides a function that is called when the diamond is upgraded or deployed to initialize state variables
  // Read about how the diamondCut function works in the EIP2535 Diamonds standard
  const DiamondInit = await ethers.getContractFactory('DiamondInit')
  const diamondInit = await DiamondInit.deploy()
  await diamondInit.deployed()
  console.log('DiamondInit deployed:', diamondInit.address)

  // Deploy facets and set the `facetCuts` variable
  console.log('')
  console.log('Deploying facets')
  const FacetNames = [
    'DiamondCutFacet',
    'DiamondLoupeFacet',
    'OwnershipFacet'
  ]
  // The `facetCuts` variable is the FacetCut[] that contains the functions to add during diamond deployment
  const facetCuts = []
  for (const FacetName of FacetNames) {
    const Facet = await ethers.getContractFactory(FacetName)
    const facet = await Facet.deploy()
    await facet.deployed()
    console.log(`${FacetName} deployed: ${facet.address}`)
    facetCuts.push({
      facetAddress: facet.address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(facet)
    })
  }

  // Creating a function call
  // This call gets executed during deployment and can also be executed in upgrades
  // It is executed with delegatecall on the DiamondInit address.
  let functionCall = diamondInit.interface.encodeFunctionData('init')

  // Setting arguments that will be used in the diamond constructor
  const diamondArgs = {
    owner: contractOwner.address,
    init: diamondInit.address,
    initCalldata: functionCall
  }

  // deploy Diamond
  const Diamond = await ethers.getContractFactory('Diamond')
  const diamond = await Diamond.deploy(facetCuts, diamondArgs)
  await diamond.deployed()
  console.log()
  console.log('Diamond deployed:', diamond.address)
  const addresses = []
  let diamondAddress;
  let diamondCutFacet;
  let diamondLoupeFacet;
  let ownershipFacet;
  diamondAddress = diamond.address;
  fs.writeFileSync("./temp_files/contract_address.txt", diamondAddress, {flag: 'w', encoding: 'utf8'})
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
  const Test2Facet = await ethers.getContractFactory("updateApartmentPriceFacet");
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
  fs.writeFileSync("./temp_files/update_facet_address.txt", test2Facet.address, {flag: 'w', encoding: 'utf8'})
  result = await diamondLoupeFacet.facetFunctionSelectors(test2Facet.address);
  assert.sameMembers(result, selectors)  
  
  const Test4Facet = await ethers.getContractFactory("getApartmentPriceFacet");
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

  logtime();
  
  // returning the address of the diamond
  return diamond.address
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deployDiamond()
    .then(() => process.exit(0))
    .catch(error => {
      console.error(error)
      process.exit(1)
    })
}

exports.deployDiamond = deployDiamond
