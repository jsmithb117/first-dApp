// executes a test run of the contract in WavePortal
const main = async () => {
  // creates and 'deploys' the contract locally
  const waveContractFactory = await hre.ethers.getContractFactory("WavePortal");
  const waveContract = await waveContractFactory.deploy({
    value: hre.ethers.utils.parseEther("0.1"),
  });
  await waveContract.deployed();
  console.log("Contract address:", waveContract.address);

  let waveCount;
  waveCount = await waveContract.getTotalWaves();
  console.log('waveCount.toNumber(): ', waveCount.toNumber());

  let contractBalance = await hre.ethers.provider.getBalance(
    waveContract.address
  );
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  // this wave should execute
  const waveTxn = await waveContract.wave("This is wave #1");
  await waveTxn.wait(); // Wait for the transaction to be mined

  contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  // this wave should not execute since it has been less than 30 seconds since last wave
  const waveTxn2 = await waveContract.wave("This is wave #2");
  await waveTxn2.wait();
  // get and log balance to check that the contract did not execute
  contractBalance = await hre.ethers.provider.getBalance(waveContract.address);
  console.log(
    "Contract balance:",
    hre.ethers.utils.formatEther(contractBalance)
  );

  // allWaves should have incremented by 1
  let allWaves = await waveContract.getAllWaves();
  console.log('allWaves: ', allWaves);
};

const runMain = (async () => {
  try {
    await main();
    process.exit(0);
  } catch (error) {
    console.log(error);
    process.exit(1);
  }
})();
