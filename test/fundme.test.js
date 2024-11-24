const { ethers } = require("hardhat")
const {assert} =require("chai")

describe("test fundme contract",async function (){

    it("test if the owner is mgs.sender",async function name() {
        const fundMeFactory =await ethers.getContractFactory("FundMe");
        const fundMe=await fundMeFactory.deploy(180);
        await fundMe.waitForDeployment();
        const [firstAccount]= await ethers.getSigner();
        assert.equal((await fundMe.owner()),firstAccount.address);
    })
})

