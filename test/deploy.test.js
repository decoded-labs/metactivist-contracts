// deploy test

const { ethers } = require("hardhat");

const expect = require("chai").expect;

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms));

let metactivists;
describe("deploy", function () {
  it("should deploy", async function () {
    const METActivists = await ethers.getContractFactory("METActivists");
    metactivists = await METActivists.deploy();
    expect(metactivists.address).to.be.a("string");
    console.log(
      "🚀 ~ file: deploy.test.js ~ line 10 ~ metactivists.address",
      metactivists.address
    );

    await network.provider.send("evm_setNextBlockTimestamp", [1650697205]);
    await network.provider.send("evm_mine");
  });

  it("should mint 1", async function () {
    await metactivists.publicMint(1, {
      value: ethers.utils.parseEther("0.07"),
    });
  });
  it("should mint 5", async function () {
    await metactivists.publicMint(5, {
      value: ethers.utils.parseEther("0.35"),
    });
  });
  it("should mint -- a lot!", async function () {
    for (let i = 0; i < 780 / 5; i++) {
      await metactivists.publicMint(5, {
        value: ethers.utils.parseEther("0.35"),
      });
    }
    await metactivists.publicMint(3, {
      value: ethers.utils.parseEther("0.21"),
    });
  });

  it("Can claim", async () => {
    await network.provider.send("evm_setNextBlockTimestamp", [1650718805]);
    await network.provider.send("evm_mine");

    const contractEthBalance = await metactivists.provider.getBalance(
      metactivists.address
    );
    console.log(ethers.utils.formatEther(contractEthBalance));

    await network.provider.request({
      method: "hardhat_impersonateAccount",
      params: ["0xc4e9ac4D7D95aA101cA8A0EabEAd26069A5dE88A"],
    });

    const signer = await ethers.getSigner(
      "0xc4e9ac4D7D95aA101cA8A0EabEAd26069A5dE88A"
    );

    const [owner] = await ethers.getSigners();
    await owner.sendTransaction({
      to: signer.address,
      value: ethers.utils.parseEther("10.0"),
    });

    await await metactivists.connect(signer).claimContribution();

    const balance = await metactivists.provider.getBalance(
      "0xc4e9ac4D7D95aA101cA8A0EabEAd26069A5dE88A"
    );

    // 55.23 * 0.05 = 2.7615
    console.log(ethers.utils.formatEther(balance));
  });
});
