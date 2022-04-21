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
  });

  it("should mint 1", async function () {
    await metactivists.publicMint(1, {
      value: ethers.utils.parseEther("0.07"),
    });
  });
  it("should mint 5", async function () {
    await metactivists.publicMint(1, {
      value: ethers.utils.parseEther("0.07"),
    });
    await sleep(5000);
  });
});
