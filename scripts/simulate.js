const hre = require("hardhat");

async function main() {
  const [deployer, attackerSigner] = await hre.ethers.getSigners();

  // DAO деплой через deployer
  const DAO = await hre.ethers.getContractFactory("TheDAO", deployer);
  const dao = await DAO.deploy();
  await dao.waitForDeployment(); // для ethers v6
  console.log("TheDAO deployed to:", dao.target); // .target вместо .address

  // Attacker деплой через attackerSigner
  const Attacker = await hre.ethers.getContractFactory("Attacker", attackerSigner);
  const attackerContract = await Attacker.deploy(dao.target);
  await attackerContract.waitForDeployment();
  console.log("Attacker deployed to:", attackerContract.target);

  // DAO пополняется от deployer
  await dao.connect(deployer).contribute({
    value: hre.ethers.parseEther("10") // v6: прямо через hre.ethers
  });

  // Атака через attackerSigner
  const tx = await attackerContract.connect(attackerSigner).attack({
    value: hre.ethers.parseEther("1"),
    gasLimit: 3_000_000
  });
  await tx.wait();

  // Баланс атакующего
  const balance = await hre.ethers.provider.getBalance(attackerContract.target);
  console.log("Attacker contract final balance:", hre.ethers.formatEther(balance), "ETH");
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
