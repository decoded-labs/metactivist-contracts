const { ethers } = require("hardhat");

async function main() {
  const MetaMock = await ethers.getContractFactory("METActivists");
  const mock20 = await Mock20.deploy("FaekGame1", "FaekGame1");
  await mock20.deployed();
  console.log("FaekGame1 Token: ", mock20.address);
}
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
