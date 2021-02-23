const Web3 = require("web3");
const web3 = new Web3();
const STAKDToken = artifacts.require("STAKDToken");
const MasterStakd = artifacts.require("MasterStakd");
const LockLiquidity = artifacts.require("LockLiquidity");
const Timelock = artifacts.require("Timelock");
const STAKDSale = artifacts.require("STAKDSale");
const VestingDev = artifacts.require("VestingDev");
const VestingTeam = artifacts.require("VestingTeam");
const admin = "0x24A6578b8ccB13043f4Ef4E131e8A591E89B1b97";
const startBlock = "5136969"; //to be changed
const vestingStartDev = "1614096000"; // 4pm utc 23 feb
const vestingStartTeam = "1629653444" // 6 month after tge
const vestingDevAmount = web3.utils.toWei("56000", "ether");
const vestingTeamAmount = web3.utils.toWei("70000", "ether");
const STAKD_BNB = "0xde24821a2d36c47ea687056130e85808b9815c99" // 300
const STAKD_BUSD = "0xeae301f15f85a26cea5c0a18dff330734de62776"// 200
const STAKD_BTC = "0xd2a31bd2240c2f1e85848a1af6e2866734c02cff" // 150
const BTC_BUSD = "0xb8875e207ee8096a929d543c9981c9586992eacb" // 10
const ETH_BUSD = "0xd9a0d1f5e02de2403f68bb71a15f8847a854b494" // 10
const BNB_BUSD = "0x1b96b92314c44b159149f7e0303511fb2fc4774f" // 10
const OIL_BNB = "0xe738c35f8DEfac2517170e3c8AC1C85fFDE6Ff2B" // 10

const saleDistro = web3.utils.toWei("374000", "ether"); //seed,private,public sale + initial liquidity + marketing fund + airdrops (more info in pitch deck)
const timeLockDelay = "1209600"; //14 days
module.exports = function (deployer) {
  deployer.then(async () => {
    //const stakdToken = await new STAKDToken("0xFfB3eDd21be33d5e78C9e0C2A275b3Fd42670D67")
    await deployer.deploy(MasterStakd,"0xFfB3eDd21be33d5e78C9e0C2A275b3Fd42670D67",admin,startBlock);
    const farming = await MasterStakd.deployed();
    await farming.add("300",STAKD_BNB,false);
    await farming.add("200",STAKD_BUSD,false);
    await farming.add("150",STAKD_BTC,false);
    await farming.add("10",BTC_BUSD,false);
    await farming.add("10",ETH_BUSD,false);
    await farming.add("10",BNB_BUSD,false);
    await farming.add("10",OIL_BNB,false);
    


    /*

 
  await deployer.deploy(STAKDSale);

    await deployer.deploy(VestingDev,"0xFfB3eDd21be33d5e78C9e0C2A275b3Fd42670D67",vestingStartDev);
    await deployer.deploy(VestingTeam,"0xFfB3eDd21be33d5e78C9e0C2A275b3Fd42670D67",vestingStartTeam);



    await deployer.deploy(STAKDToken);
    await stakdToken.mint(admin, saleDistro);
    await deployer.deploy(Timelock, admin, timeLockDelay);
    await deployer.deploy(LockLiquidity);


    //mint tokens to admin to use for, seed round distro, private round distro, public sale distro, packakeswap liqudity, marketing fund, airdrops

   
*/
  });
};
