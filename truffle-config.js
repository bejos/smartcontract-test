
require('dotenv').config()
const PrivateKeyProvider = require("truffle-privatekey-provider");
const pkey = process.env.PKEY;
const ganache = "0xfcdddbeb8fcac5de004e0c69dc603ecb3a70791a6ac107dc573294058a2b7e07"
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
    provider: () => new PrivateKeyProvider(pkey, `https://data-seed-prebsc-1-s3.binance.org:8545/`), 
    network_id: 97,
    confirmations: 1,
    timeoutBlocks: 200,
    skipDryRun: true
   },
   bsc: {
    provider: () => new PrivateKeyProvider(pkey, `https://bsc-dataseed.binance.org`),
    network_id: 56,
    confirmations: 1,
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
  api_keys: {
    bscscan: '8QHPDDNYV9M73YJV6EMHAPA3VX7QNPSUDV'
  },
  plugins: [
    'truffle-plugin-verify'
  ]
};
