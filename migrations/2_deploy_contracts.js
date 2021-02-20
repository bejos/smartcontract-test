const Web3 = require("web3");
const web3 = new Web3();
const STAKDToken = artifacts.require("STAKDToken");
const MasterStakd = artifacts.require("MasterStakd");
const LockLiquidity = artifacts.require("LockLiquidity");
const Timelock = artifacts.require("Timelock");
const STAKDSale = artifacts.require("STAKDSale");
const VestingDev = artifacts.require("VestingDev");
const VestingTeam = artifacts.require("VestingTeam");
const admin = "0x24A6578b8ccB13043f4Ef4E131e8A591E89B1b97"
const startBlock = "1234" //to be changed
const vestingStart ="123123"//to be changed
const vestingDevAmount = web3.utils.toWei("56000","ether");
const vestingTeamAmount = web3.utils.toWei("100000","ether");
const saleDistro = web3.utils.toWei("344000","ether"); //seed,private,public sale + initial liquidity + marketing fund + airdrops (more info in pitch deck)
const timeLockDelay = "1209600" //14 days
module.exports = function(deployer) {
 
  deployer.then(async()=>{
    await deployer.deploy(STAKDToken);
    const stakdToken = await STAKDToken.deployed();
    await deployer.deploy(MasterStakd,stakdToken.address,admin,startBlock);
    await deployer.deploy(LockLiquidity);
    await deployer.deploy(Timelock,admin,timeLockDelay);
    await deployer.deploy(STAKDSale);
    await deployer.deploy(VestingDev,stakdToken.address,vestingStart);
    await deployer.deploy(VestingTeam,stakdToken.address,vestingStart);
    const vestingDev = await VestingDev.deployed();
    const vestingTeam = await VestingTeam.deployed();

    //mint tokens to admin to use for, seed round distro, private round distro, public sale distro, packakeswap liqudity, marketing fund, airdrops

    await stakdToken.mint(vestingDev.address,vestingDevAmount);
    await stakdToken.mint(vestingTeam.address,vestingTeamAmount);
    await stakdToken.mint(admin,saleDistro);

    console.log(await stakdToken.totalSupply())

  })

};