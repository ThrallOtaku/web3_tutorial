require("@nomicfoundation/hardhat-toolbox");
require("@chainlink/env-enc").config();

// alchemy 上注册的sepolia 测试网络地址,选择以太坊的的sepolia 测试网
const SEPOLIA_URL=process.env.SEPOLIA_URL;
 //metamask 的私钥。测试账户
const PRIVATE_KEY=process.env.PRIVATE_KEY;
const API_KEY= process.env.API_KEY;
/**import('hardhat/config').HardhatUserConfig */
module.exports = {
  solidity: "0.8.27",

  networks:{
    sepolia:{
      url:SEPOLIA_URL,
      accounts:[PRIVATE_KEY]
    },
    etherscan:{
      url:"https://etherscan.io",
      apiKey:"etherscan.io 获取的api key"
    }
  }
};
