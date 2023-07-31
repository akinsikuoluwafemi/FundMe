// const { getNamedAccounts, ethers } = require("hardhat");

// async function main() {
//     const { deployer } = await getNamedAccounts();

//     const FundMeContractFactory = await ethers.getContractFactory("FundMe");
//     console.log("FundMeContractFactory", FundMeContractFactory);
//     const fundMe = FundMeContractFactory.connect(deployer).deploy();
//     // const transactionResponse = await fundMe.fund({
//     //     value: ethers.utils.parseEther("0.1"),
//     // });
//     // await transactionResponse.wait(1);
//     // console.log("Funded");
// }

// main();

const { ethers, getNamedAccounts } = require("hardhat");

async function main() {
    const { deployer } = await getNamedAccounts();
    const FundMeContractFactory = await ethers.getContractFactory("FundMe");
    const fundMe = await FundMeContractFactory.deploy();
    console.log(`Got contract FundMe at ${fundMe.address}`);
    console.log("Funding contract...");
    const transactionResponse = await fundMe.fund({
        value: ethers.utils.parseEther("0.1"),
    });
    await transactionResponse.wait();
    console.log("Funded!");
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });
