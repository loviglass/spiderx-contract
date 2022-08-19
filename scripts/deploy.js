// scripts/deploy.js
const hre = require("hardhat");

async function main() {
  const SpiderX = await hre.ethers.getContractFactory("SpiderX");
  const spiderX = await SpiderX.deploy();

  await spiderX.deployed();

  console.log("SpiderX deployed to:", spiderX.address);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });