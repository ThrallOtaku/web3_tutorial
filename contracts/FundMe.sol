// 开源协议
//SPDX-License-Identifier:MIT
//指定solidity  版本
pragma solidity ^0.8.20;
// comment : this is my first smart contract
// spdx license

//https://docs.chain.link/  预言机文档,引入chainlink 预言机
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

//需求 1.创建一个收款函数
//2. 记录投资人并且查看

//3. 在锁定期内，达到目标值，生产商可以提款
//4. 在锁定期内，没有达到目标值，投资人在锁定期以后退款

contract FundMe {
    mapping(address => uint256) public fundersToAmount;

    uint256 constant MINIMUM_VALUE = 100 * 10**18; //wei

    //constant常量不可变
    uint256 constant TARGET = 1000;

    //unix 时间 https://www.unixtimestamp.com
    //避免了时区的来回转换
    uint256 deploymentTimeStamp;
    //锁定的时间
    uint256 lockTime;

    address erc20Addr;
    address public owner;
    //https://docs.chain.link/data-feeds/getting-started
    //合约作为类型。这里合约的意思就是java中的class。搞半天。
    //引入dataFeed
    AggregatorV3Interface internal dataFeed;

    //构造函数合约被部署的时候被调用一次
    constructor(uint256 _lockTime) {
        dataFeed = AggregatorV3Interface(
            //sepolia test
            0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        );
        //部署这个合约的人的地址
        owner = msg.sender;
        deploymentTimeStamp = block.timestamp; //部署交易所在区块的时间
        //
        lockTime = _lockTime;
    }

    //payable = 收取 native tokan ，左边deploy以后fund 是红色的
    //wei 最小单位，Gwei 是wei的9次方，finney是Gwei的6次方，Ether是finney的3次方
    //向合约转账1ETH以后，合约地址会变成1ETH。
    function fund() external payable {
        //TODO  require 和if 的区别
        require(convertEthToUsd(msg.value) >= MINIMUM_VALUE, "Send more ETH");

        require(
            block.timestamp < deploymentTimeStamp + lockTime,
            "window is closed"
        );
        //storage存储fund人和fund金额 数据
        fundersToAmount[msg.sender] = msg.value;
    }

    /**
     * Returns the latest answer.
     */
    function getChainlinkDataFeedLatestAnswer() public view returns (int256) {
        // prettier-ignore
        (
            /* uint80 roundID */,
            int answer,
            /*uint startedAt*/,
            /*uint timeStamp*/,
            /*uint80 answeredInRound*/
        ) = dataFeed.latestRoundData();
        return answer;
    }

    //读取数据用view
    function convertEthToUsd(uint256 ehtAmount)
        internal
        view
        returns (uint256)
    {
        //数据类型强制转换
        uint256 ethPrice = uint256(getChainlinkDataFeedLatestAnswer());
        return (ethPrice * ehtAmount) / (10**8);
        //eth /usd   precision =10**8
        //x /eth  precision =10**18
    }

    //windowClosed  替换方法体中的require 方法
    function getFund() external WindowClosed {
        //address(this).balance 当前合约余额
        require(address(this).balance >= TARGET, "Target is not reached");
        require(
            msg.sender == owner,
            "this function can only be called by owner"
        );

        //用方法声明中的WindowClosed 替换下面这段代码
        // require(
        //     block.timestamp >= deploymentTimeStamp + lockTime,
        //     "window is not closed"
        // );
        //transfer，失败了会revert
        payable(msg.sender).transfer(address(this).balance);

        //send return false if failed
        bool success = payable(msg.sender).send(address(this).balance);
        require(success, "transaction failed");

        //call
        bool success2;
        (success2, ) = payable(msg.sender).call{value: address(this).balance}(
            ""
        );
        require(success2, "transfer tx failed");
        //fund 的人fund的钱需要置为0，否则可以无限refund
        fundersToAmount[msg.sender] = 0;
    }

    function refund() external {
        require(
            convertEthToUsd(address(this).balance) < TARGET,
            "Target is reached"
        );
        require(fundersToAmount[msg.sender] != 0, "there is no fund for you ");
        require(
            block.timestamp >= deploymentTimeStamp + lockTime,
            "window is not closed"
        );
        //call
        bool success;
        (success, ) = payable(msg.sender).call{
            value: fundersToAmount[msg.sender]
        }("refund");
    }

    //修改owner
    function trasferOwner(address newOwner) public {
        require(
            msg.sender == owner,
            "this function can only be called by owner"
        );
        owner = newOwner;
    }

    //抽象出方法，统一在方法声明的地方调用
    modifier WindowClosed() {
        require(
            block.timestamp >= deploymentTimeStamp + lockTime,
            "window is not closed"
        );
        //下划线之前执行判定,下划线也可以放在require之前
        _;
    }

    modifier onlyOwnder(){
        require(msg.sender==owner,"this function can only be called by owner");
        _;
    }

    function setFunderToAmount(address funderAddr,uint amountToUpdate) external  {
        require(msg.sender==erc20Addr,"no permission to call");
        fundersToAmount[funderAddr]=amountToUpdate;

    }

    function setErc20Addr(address _erc20Addr)public onlyOwnder{
        erc20Addr =_erc20Addr;
    }
}
