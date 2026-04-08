async function main() {
    // Getting the contract factory for SmallNormalPrimitive
    const SmallNormalPrimitive = await ethers.getContractFactory("SmallNormalPrimitive");

    for (let i = 1; i <= 28; i++) {
        console.log(`Deploying contract instance ${i}...`);

        // Deploy the contract
        const smallNormalPrimitive = await SmallNormalPrimitive.deploy();

        // Wait for the deployment to be mined and get the transaction receipt
        const txReceipt = await smallNormalPrimitive.deployTransaction.wait();

        // Log the address of the deployed contract
        console.log(`SmallNormalPrimitive instance ${i} deployed to:`, smallNormalPrimitive.address);

        // Log the gas used for deployment
        console.log(`Gas used for instance ${i}:`, txReceipt.gasUsed.toString());

        // Store data by invoking set function
        const txStore = await smallNormalPrimitive.set(i); // Storing 'i' as data
        const receiptStore = await txStore.wait(); // Wait for the transaction to be mined
        console.log(`Gas used for set(${i}) in instance ${i}:`, receiptStore.gasUsed.toString());

        // Retrieve data by invoking get function
        const data = await smallNormalPrimitive.get();
        console.log(`Data retrieved from instance ${i}:`, data.toString());
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

