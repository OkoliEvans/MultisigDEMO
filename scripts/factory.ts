
import { ethers } from "hardhat";

async function main() {
  const [owner, Admin2] = await ethers.getSigners();
  const admin = [owner.address, Admin2.address, "0x49207A3567EF6bdD0bbEc88e94206f1cf53c5AfC"];

  /** 
  const CloneMultiSig = await ethers.getContractFactory("cloneMultiSig");
  //console.log(await ethers.getContractFactory("cloneMultiSig"));
  
  const cloneMultiSig = await CloneMultiSig.deploy();
  await cloneMultiSig.deployed();

  console.log(`Multisig Address is ${cloneMultiSig.address}`);

  const newMultisig = await cloneMultiSig.createMultiSig(admin);
  let event = await newMultisig.wait();
  let newChild = event.events[0].args[0];
  console.log(newChild);  */

  //////////////////////////////////////////////////

  const childMultisig = await ethers.getContractAt("IMultisig", "0x2a33097742dc475b9A1e394C3D2e98c14FC3588a");
  const addresses = await childMultisig.returnAdmins();
  console.log(addresses);

  await childMultisig.addAdmin("0x96ADF9Aedf72b6F4BEAE7EFFB20e657c206ee34f");
  await childMultisig.connect(Admin2).addAdmin("0x96ADF9Aedf72b6F4BEAE7EFFB20e657c206ee34f");

  const addressesNew = await childMultisig.returnAdmins();
  console.log(addressesNew);
}

// We recommend this pattern to be able to use async/await everywhere
// and properly handle errors.
main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});