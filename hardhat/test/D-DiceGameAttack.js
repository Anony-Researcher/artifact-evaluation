const { expect, assert } = require("chai");
const hre = require("hardhat");
const { deployDiceGame } = require("../scripts/D-DiceAttack");
const { deployDiamond } = require("../scripts/deploy");
describe("Deployment", function () {

    let diamondAddress;       
    before(async function () {
        await deployDiceGame()
    })
    it("deploy contracts",()=>{
        console.log(diamondAddress)
        assert(true,true)
    })
})

