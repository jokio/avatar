// We require the Hardhat Runtime Environment explicitly here. This is optional
// but useful for running the script in a standalone fashion through `node <script>`.
//
// When running the script with `npx hardhat run <script>` you'll find the Hardhat
// Runtime Environment's members available in the global scope.
import { ethers, run, upgrades } from "hardhat";

const proxyAddress = "0x2C56a86Ae5e6Ed9Dd00E91E023382dEbdcE9214A";

async function main() {
  const AvatarPack = await ethers.getContractFactory("AvatarPack");

  const newInstanceAddress = await upgrades.prepareUpgrade(
    proxyAddress,
    AvatarPack
  );
  console.log("newInstanceAddress", newInstanceAddress);

  const upgraded = await upgrades.upgradeProxy(proxyAddress, AvatarPack);

  console.log("upgraded", upgraded.address, await upgraded.resolvedAddress);

  await sleep(2000);
  console.log("started verification process");

  await run("verify:verify", {
    address: newInstanceAddress,
    constructorArguments: [],
  }).catch((err: any) => {
    if (err.message === "Contract source code already verified") {
      return;
    }

    throw err;
  });
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});

export function sleep(ms: number) {
  return new Promise((resolve) => setTimeout(resolve, ms));
}
