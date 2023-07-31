// import
//main function
//calling of main function

const { network } = require("hardhat");
const {
    networkConfig,
    developmentChains,
} = require("../helper-hardhat-config");
require("dotenv").config();
const { verify } = require("../utils/verify");

// hardhat runtime environment

// function deployFunc(hre) {
// const { getNamedAccounts, deployments } = hre
//     console.log("HI!");
// }

// module.exports.default = deployFunc;
// hre is being destructured
module.exports = async ({ getNamedAccounts, deployments }) => {
    const { deploy, log } = deployments;
    const { deployer } = await getNamedAccounts();
    const chainId = network.config.chainId;

    //when going for localhost or hardhat networks we want to use a mock
    let ethUsdPriceFeedAddress;
    // if (chainId == 11155111) {
    if (developmentChains.includes(network.name)) {
        //chain is sepolia (development)
        const ethUsdAggregator = await deployments.get("MockV3Aggregator");
        ethUsdPriceFeedAddress = ethUsdAggregator.address;
    } else {
        ethUsdPriceFeedAddress = networkConfig[chainId]["ethUsdPriceFeed"];
    }
    const args = [ethUsdPriceFeedAddress];
    // the idea of mock contract is, if the contract doesn't exist, we deploy a minimal version of our local testing
    const fundMe = await deploy("FundMe", {
        from: deployer,
        args, //put all the arguments you want to deploy the contract with,
        log: true,
        waitConfirmations: network.config.blockConfirmations || 1,
    });
    if (
        !developmentChains.includes(network.name) &&
        process.env.ETHERSCAN_API_KEY
    ) {
        // VERIFY
        await verify(fundMe.address, args);
    }
    log("--------------------------");
};

module.exports.tags = ["all", "fundme"];
