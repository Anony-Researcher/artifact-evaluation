const { expect, assert } = require("chai");
const hre = require("hardhat");
const { deployAuction} = require("../scripts/D-deploySavings")
describe("Deployment", function () {

    let diamondAddress;
    before(async function () {
        let accounts = await ethers.getSigners();
        const diamondAddress = await deployAuction()
        const bankAmount = ethers.utils.parseEther("4");
        const SavingsBank = await ethers.getContractAt("depositFacet",diamondAddress);
        savingsBank = await SavingsBank.connect(accounts[0]).deposit({ value: bankAmount, });
        const getBalanceFacet = await ethers.getContractAt("getBalanceFacet", diamondAddress);
        console.log(
            `SavingsBank with ${ethers.utils.formatEther(
                bankAmount
            )}ETH deployed with address ${diamondAddress}`
        );

        const Attacker = await ethers.getContractFactory("Attacker");
        attacker = await Attacker.connect(accounts[1]).deploy(diamondAddress);
console.log(
            `Attacker deployed with ${ethers.utils.formatEther(await attacker.getBalance())}`
        );

        await attacker.attack({ value: ethers.utils.parseEther("1"), gasLimit: 5000000,});
        console.log(
            `SavingsBank has ${ethers.utils.formatEther(await
                getBalanceFacet.getBalance()
            )}ETH now`
        );
        console.log(
            `Attacker has ${ethers.utils.formatEther(
                await attacker.getBalance())} now`
        );
    })
    it("deploy contracts", () => {
        console.log("sample test")
        assert(true, true)
    })
})
