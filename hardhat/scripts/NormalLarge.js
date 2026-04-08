const { ethers } = require("hardhat");

async function main() {
  // Getting the contract factory for NormalLarge
  const NormalLarge = await ethers.getContractFactory("NormalLarge");

  for (let i = 1; i <= 28; i++) {
    console.log(`Deploying NormalLarge instance ${i}...`);

    // Deploy the contract
    const normalLarge = await NormalLarge.deploy();

    // Wait for the deployment to be mined and get the transaction receipt
    const txReceipt = await normalLarge.deployTransaction.wait();

    // Log the address of the deployed contract
    console.log(`NormalLarge instance ${i} deployed to:`, normalLarge.address);

    // Log the gas used for deployment
    console.log(`Gas used for deployment of instance ${i}:`, txReceipt.gasUsed.toString());

    // Generate random values
    const dataToStore = Math.floor(Math.random() * 100); // Random number between 0-99
    const a = Math.floor(Math.random() * 50); // Random number between 0-49
    const b = Math.floor(Math.random() * 50); // Random number between 0-49

    // Store data by invoking storeData function
    const txStore = await normalLarge.storeData(dataToStore);
    const receiptStore = await txStore.wait(); // Wait for the transaction to be mined
    console.log(`Gas used for storeData(${dataToStore}) in instance ${i}:`, receiptStore.gasUsed.toString());

    // To calculate gas for compute, we can use the `callStatic` method
    const gasEstimate = await normalLarge.estimateGas.compute(a, b);
    console.log(`Gas estimate for compute(${a}, ${b}) in instance ${i}:`, gasEstimate.toString());

    // Example of sending payment (you can specify a test address here)
    const testAddress = "0xb794f5ea0ba39494ce839613fffba74279579268"; // Replace with a valid address
    const txPayment = await normalLarge.sendPayment(testAddress, { value: ethers.utils.parseEther("0.01") });
    const receiptPayment = await txPayment.wait(); // Wait for the transaction to be mined
    console.log(`Gas used for sendPayment in instance ${i}:`, receiptPayment.gasUsed.toString());
  }
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });

