const { ethers } = require("hardhat");

async function main() {
  const MetaMock = await ethers.getContractFactory("METActivists");
  const metaMock = await MetaMock.deploy();
  await metaMock.deployed();
  console.log("METActivists deployed: ", metaMock.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
