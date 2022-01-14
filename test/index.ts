import { expect } from "chai";
import { ethers } from "hardhat";

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const AvatarPack = await ethers.getContractFactory("AvatarPack");
    const avatarPack = await AvatarPack.deploy();
    await avatarPack.deployed();

    expect(await avatarPack.greet()).to.equal("Hello");

    const setGreetingTx = await avatarPack.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await avatarPack.greet()).to.equal("Hola, mundo!");
  });
});
