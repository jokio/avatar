import { expect } from "chai";
import { ethers } from "hardhat";

describe("AvatarPack", function () {
  it("Should create the contract and get prices", async function () {
    const AvatarPack = await ethers.getContractFactory("AvatarPack");
    const avatarPack = await AvatarPack.deploy(
      100,
      300,
      3,
      "QmdbsoKEVGCV9ojAHGM8mVAMyycmfLAX9Ds6SxaA1NKHJA",
      [1, 10, 30, 10],
      [1, 1, 1, 1],
      true
    );
    await avatarPack.deployed();

    expect(await avatarPack.boxPrice()).to.equal(100);
    expect(await avatarPack.packPrice()).to.equal(300);
  });
});
