
const PrivateKeyProvider = require("truffle-privatekey-provider");
const pkey = process.env.PKEY;
const ganache = "0x8e712f375e3a49ee1a7295682057da04277d68b4c61bd29deb2bcd5658160eba"
module.exports = {
  // Uncommenting the defaults below
  // provides for an easier quick-start with Ganache.
  // You can also follow this format for other networks;
  // see <http://truffleframework.com/docs/advanced/configuration>
  // for more details on how to specify configuration options!
  //
  networks: {
   development: {
    provider: () => new PrivateKeyProvider(ganache, `http://localhost:8545`),
     network_id: "*"
   },
   bsctest: {
    provider: () => new PrivateKeyProvider(pkey, `https://data-seed-prebsc-1-s1.binance.org:8545`),
    network_id: 97,
    confirmations: 10,
    timeoutBlocks: 200,
    skipDryRun: true
   },
   bsc: {
    provider: () => new PrivateKeyProvider(pkey, `https://bsc-dataseed.binance.org`),
    network_id: 56,
    confirmations: 10,
    timeoutBlocks: 200,
    skipDryRun: true
   }
  },  
  compilers: {
    solc: {
      settings: {          // See the solidity docs for advice about optimization and evmVersion
        optimizer: {
          enabled: true,
          runs: 200
        },
       },
      version: "0.6.12"
    }
  },
};
