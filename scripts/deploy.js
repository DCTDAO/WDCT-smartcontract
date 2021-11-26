// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.

const hre = require("hardhat");
const { ethers } = require("hardhat");


async function main() {
  
  const wdctaddr = "0xe8f25f2CCF97f3d08f9490dCBa6e67637338c6c8";
  const dusdt = "0x017801B52F3e40178C75C4B4f19f1a0c8F8A0b78";
  const dctd = "0x8Db2dBdFB50480FE79F6576deAA4f6E68DcBfb15";

  const dctdaoFactory = "0xFBA564939397e71c75c9CbB29E6E23b89e4272BE";
  
  const WDCTHANDLER = await ethers.getContractFactory("WDCThandler");
  const WDCThandler = await WDCTHANDLER.deploy(dusdt, dctd);
  await WDCThandler.deployed();
  console.log("WDCTHANDLER addr:", WDCThandler.address);
  
  console.log("[*] Setting WDCT");
  await WDCThandler.setWDCT(wdctaddr);
  console.log("[*] Setting Factory");
  await WDCThandler.setFactory(dctdaoFactory);
  console.log("[*] Setting fee in DUSDT");
  await WDCThandler.setUsdFee(ethers.utils.parseUnits("5",6)); // DUSDT has 6 decimal places

  console.log("[*] Setting mint ROLE");
  //console.log("[*] Can not set mint role without Permission");
  //set a role, need permistion for that
  const wdctContract = await ethers.getContractFactory("WDCT");
  const wdct = await wdctContract.attach(wdctaddr);
  const mintRole = await wdct.MINTER_ROLE();
  await wdct.grantRole(mintRole, this.WDCThandler.address); 
  console.log("Finished")
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
