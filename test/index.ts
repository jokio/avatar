import { expect } from "chai";
import { ethers } from "hardhat";

describe("Greeter", function () {
  it("Should return the new greeting once it's changed", async function () {
    const AvatarPack = await ethers.getContractFactory("AvatarPack");
    const avatarPack = await AvatarPack.deploy("Hello, world!");
    await avatarPack.deployed();

    expect(await avatarPack.greet()).to.equal("Hello, world!");

    const setGreetingTx = await avatarPack.setGreeting("Hola, mundo!");

    // wait until the transaction is mined
    await setGreetingTx.wait();

    expect(await avatarPack.greet()).to.equal("Hola, mundo!");
  });
});
