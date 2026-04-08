/* global ethers */
/* eslint prefer-const: "off" */
const { ethers } = require("hardhat");
const { getSelectors, FacetCutAction } = require('./libraries/diamond.js');

async function deployDiamond() {
  const accounts = await ethers.getSigners();
  const contractOwner = accounts[0];

  let totalGasUsed = ethers.BigNumber.from(0);

  // Deploy DiamondInit
  // DiamondInit provides a function that is called when the diamond is upgraded or deployed to initialize state variables
  // Read about how the diamondCut function works in the EIP2535 Diamonds standard
  const DiamondInit = await ethers.getContractFactory('DiamondInit');
  const diamondInit = await DiamondInit.deploy();
  const diamondInitTx = await diamondInit.deployed();
  const diamondInitReceipt = await diamondInitTx.deployTransaction.wait();
  totalGasUsed = totalGasUsed.add(diamondInitReceipt.gasUsed);
  console.log('DiamondInit deployed:', diamondInit.address);

  // Deploy facets and set the `facetCuts` variable
  console.log('');
  console.log('Deploying facets');
  const FacetNames = [
    'DiamondCutFacet',
    'DiamondLoupeFacet',
    'OwnershipFacet'
  ];

  // The `facetCuts` variable is the FacetCut[] that contains the functions to add during diamond deployment
  const facetCuts = [];
  for (const FacetName of FacetNames) {
    const Facet = await ethers.getContractFactory(FacetName);
    const facet = await Facet.deploy();
    const facetTx = await facet.deployed();
    const facetReceipt = await facetTx.deployTransaction.wait();
    totalGasUsed = totalGasUsed.add(facetReceipt.gasUsed);
    console.log(`${FacetName} deployed: ${facet.address}`);
    facetCuts.push({
      facetAddress: facet.address,
      action: FacetCutAction.Add,
      functionSelectors: getSelectors(facet)
    });
  }

  // Creating a function call
  // This call gets executed during deployment and can also be executed in upgrades
  // It is executed with delegatecall on the DiamondInit address.
  let functionCall = diamondInit.interface.encodeFunctionData('init');

  // Setting arguments that will be used in the diamond constructor
  const diamondArgs = {
    owner: contractOwner.address,
    init: diamondInit.address,
    initCalldata: functionCall
  };

  // Deploy Diamond
  const Diamond = await ethers.getContractFactory('Diamond');
  const diamond = await Diamond.deploy(facetCuts, diamondArgs);
  const diamondTx = await diamond.deployed();
  const diamondReceipt = await diamondTx.deployTransaction.wait();
  totalGasUsed = totalGasUsed.add(diamondReceipt.gasUsed);

  console.log('');
  console.log('Diamond deployed:', diamond.address);
  console.log('Total gas used for deploying Diamond and facets:', totalGasUsed.toString());

  // Returning the diamond object and total gas used
  return { diamond, totalGasUsed };
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
if (require.main === module) {
  deployDiamond()
    .then(({ diamond, totalGasUsed }) => {
      console.log('Deployment complete.');
      console.log('Total gas used:', totalGasUsed.toString());
      process.exit(0);
    })
    .catch(error => {
      console.error(error);
      process.exit(1);
    });
}

exports.deployDiamond = deployDiamond;