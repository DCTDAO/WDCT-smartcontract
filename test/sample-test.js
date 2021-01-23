const { expect } = require("chai");

describe("WDCT", function() {
  it("WDCT tests", async function() {
    const WDCT = await ethers.getContractFactory("WDCT");
    const wdct = await WDCT.deploy();
    
    await wdct.deployed();
    //expect(await greeter.greet()).to.equal("Hello, world!");

    //await greeter.setGreeting("Hola, mundo!");
    //expect(await greeter.greet()).to.equal("Hola, mundo!");
  });
});
