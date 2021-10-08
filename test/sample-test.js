const { expect } = require("chai");
const { ethers } = require("hardhat");

async function sign(signer, contractAddr, receiverAddr, amount, txId){
  const domain = {
    name: 'WDCThandler',
    version: '1',
    chainId: 31337,
    verifyingContract: contractAddr
  };
  const types = {
    Deposit: [
            { name: 'receiver', type: 'address' },
            { name: 'amount',type: 'uint256' },
            {name: 'txId',type: 'bytes20'}
    ]
  };
  const message = {
    receiver: receiverAddr,
    amount: amount,
    txId: txId,
  };
  return signer._signTypedData(domain, types, message);
}

describe("WDCThandler", function () {
  beforeEach(async function() {
    this.WDCT = await ethers.getContractFactory("WDCT");
    this.WDCTHANDLER = await ethers.getContractFactory("WDCThandler");
    this.wdct = await this.WDCT.deploy();
    this.WDCThandler = await this.WDCTHANDLER.deploy();
    await this.wdct.deployed();
    await this.WDCThandler.deployed();
    
    await this.WDCThandler.setWDCT(this.wdct.address);

    const mintRole = await this.wdct.MINTER_ROLE();
    await this.wdct.grantRole(mintRole, this.WDCThandler.address);
  });
  it("Should mint tokens and used", async function () {
    const [signer, account1] = await ethers.getSigners()
    const signature = await sign(
      signer, 
      this.WDCThandler.address, 
      account1.address, 
      10000,
      '0x89c12806a3209f24df3639bdc631943300533b13');
    await this.WDCThandler.deposit(account1.address, 10000,'0x89c12806a3209f24df3639bdc631943300533b13', signature);
    

    expect(await this.wdct.balanceOf(account1.address)).to.equal(10000);
    expect(await this.wdct.totalSupply()).to.equal(10000);

    await expect(this.WDCThandler.deposit(account1.address, 10000,'0x89c12806a3209f24df3639bdc631943300533b13', signature)).to.be.reverted;
  });
  it("Invalid signature/signer/params", async function() {
    const [signer, account1] = await ethers.getSigners()
    const signature = await sign(
      account1, 
      this.WDCThandler.address, 
      account1.address, 
      10000,
      '0x89c12806a3209f24df3639bdc631943300533b14');
      await expect(this.WDCThandler.deposit(account1.address, 10000,'0x89c12806a3209f24df3639bdc631943300533b14', signature))
      .to.be.reverted;

      const signature2 = await sign(
        signer, 
        this.WDCThandler.address, 
        account1.address, 
        10000,
        '0x89c12806a3209f24df3639bdc631943300533b14');
      
      await expect(this.WDCThandler.deposit(account1.address, 100000,'0x89c12806a3209f24df3639bdc631943300533b14', signature))
      .to.be.reverted;
      await expect(this.WDCThandler.deposit(signer.address, 100000,'0x89c12806a3209f24df3639bdc631943300533b14', signature))
      .to.be.reverted;
      await expect(this.WDCThandler.deposit(account1.address, 10000,'0x89c12806a3209f24df3639bdc63194xxxxxxxxxx', signature))
      .to.be.reverted;

  });
});
