require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();
require("hardhat-gas-reporter");

module.exports = {
  solidity: {
    version: "0.8.4",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },

  networks: {
    mainnet: {
      url: process.env.MAINNET_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    polygon: {
      url: process.env.POLYGON_URL || "",
      accounts:
        process.env.PRIVATE_KEY !== undefined ? [process.env.PRIVATE_KEY] : [],
    },
    gasReporter: {
      currency: "USD",
      gasPrice: 50,
      token: "ETH",
      gasPriceApi:
        "https://api.etherscan.io/api?module=proxy&action=eth_gasPrice",
      coinmarketcap: "9c854297-1257-4678-8532-7b9f82aba3a4",
    },
  },
  etherscan: {
    apiKey: process.env.POLYGON_ETHERSCAN_KEY,
  },
};
