
//1.import ethers.js
//2.create main function
//3.execute main function

//contract address is 0x5FbDB2315678afecb367f032d93F642f64180aa3
//

const { ethers } = require("hardhat");

async function main() {
    //create factory。 需要等待factory 创建完成，function前面需要加入async
    //等创建好factory 才能执行下一个语句
    const fundMeFactory = await ethers.getContractFactory("FundMe");

    //deploy contract from factory,部署也不是马上可以完成的
    const fundMe = await fundMeFactory.deploy(10);
    //等合约入块
    await fundMe.waitForDeployment();
    //fundMe.target  合约部署的地址
    console.log(`contract has been delpoyed successfully,contract address is ${fundMe.target}`);

    //vertify fundme
    //11155111 测试链是sepolia 测试网络，以及存在apiKEY
    if(hre.network.config.chainId==11155111&& process.env.API_KEY){
        console.log("waiting for 5 confirms");
        await fundMe.deploymentTransaction.wait(5);
        await verifyFundMe(fundMe.target,[10]);
    }else{
        console.log("verification skipped....");
    }

    //TODO init 2 accounts
    //TODO fund contract with first account
    //TODO fund contract with second account 默认选择第一个账户。需要显式调用第二个账户
    //TODO check balance of contract
    //check mapping。 firstAccountBalance ,secondAccountBalance
    //


    await fundMe.deploymentTransaction.wait(5);
    console.log('waiting for 5 confirmations');

    //hre 运行时环境。 调用
    await hre.run("verify:verify", {
        address: contractAddress,
        constructorArguments: [10],
    });

}

//(error) 函数入参
main().then().catch((error) => {
    console.error(error)
    process.exit(1)

})