const { expect, assert } = require("chai");
const hre = require("hardhat");
const { deployDiceGame } = require("../scripts/D-deployDiceGame");
describe("Deployment", function () {

    let diamondAddress;
    before(async function () {
        let accounts = await ethers.getSigners();
        const diamondAddress = await deployDiceGame();
        const Amount = ethers.utils.parseEther("4");
        const diceGame = await ethers.getContractAt("DiceGame", diamondAddress);
        // diceGame = await DiceGame.deploy({ value: Amount, });       
        const [owner] = await ethers.getSigners();

        const transactionHash = await owner.sendTransaction({
            to: diamondAddress,
            value: ethers.utils.parseEther("5.0"), // Sends exactly 1.0 ether
        });
        console.log(
            `DiceGame with ${ethers.utils.formatEther(
                Amount
)}ETH deployed with address ${diceGame.address}`
        );

        const Attacker = await ethers.getContractFactory("AttackerDice");
        attacker = await Attacker.deploy(diamondAddress);

        console.log(
            `Attacker deployed with ${ethers.utils.formatEther(
                await attacker.getBalance())}`
        );

        await attacker.attack();
        console.log(
            `DiceGame has ${ethers.utils.formatEther(
                await diceGame.getBalance()
            )}ETH now`
        );
        console.log(
            `Attacker has ${ethers.utils.formatEther(
                await attacker.getBalance())} now`
        );
await attacker.attack();
        console.log(
            `DiceGame has ${ethers.utils.formatEther(
                await diceGame.getBalance()
            )}ETH now`
        );
        console.log(
            `Attacker has ${ethers.utils.formatEther(
                await attacker.getBalance())} now`
        );

        await attacker.attack();
        console.log(
            `DiceGame has ${ethers.utils.formatEther(
                await diceGame.getBalance()
            )}ETH now`
        );
        console.log(
            `Attacker has ${ethers.utils.formatEther(
                await attacker.getBalance())} now`
);

        await attacker.attack();
        console.log(
            `DiceGame has ${ethers.utils.formatEther(
                await diceGame.getBalance()
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

