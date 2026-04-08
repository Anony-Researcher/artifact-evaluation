async function main() {
    // Getting the contract factory for NormalMedium
    const NormalMedium = await ethers.getContractFactory("NormalMedium");

    for (let i = 1; i <= 28; i++) {
        console.log(`Deploying contract instance ${i}...`);

        // Deploy the contract
        const normalMedium = await NormalMedium.deploy();

        // Wait for the deployment to be mined and get the transaction receipt
        const txReceipt = await normalMedium.deployTransaction.wait();

        // Log the address of the deployed contract
        console.log(`NormalMedium instance ${i} deployed to:`, normalMedium.address);

        // Log the gas used for deployment
        console.log(`Gas used for instance ${i} deployment:`, txReceipt.gasUsed.toString());

        // Store data by invoking storeData function
        const dataToStore = i; // Example data to store
        const nameToStore = `Name${i}`; // Example name to store

        const txStore = await normalMedium.storeData(dataToStore, nameToStore); // Storing data
        const receiptStore = await txStore.wait(); // Wait for the transaction to be mined
        console.log(`Gas used for storeData(${dataToStore}, "${nameToStore}") in instance ${i}:`, receiptStore.gasUsed.toString());

        // Add an address by invoking addAddress function
        const addressToAdd = "0xb794f5ea0ba39494ce839613fffba74279579268"; // Example valid address

        const txAddAddress = await normalMedium.addAddress(addressToAdd); // Adding address
        const receiptAddAddress = await txAddAddress.wait(); // Wait for the transaction to be mined
        console.log(`Gas used for addAddress(${addressToAdd}) in instance ${i}:`, receiptAddAddress.gasUsed.toString());

        // Update balance by invoking updateBalance function
        const amountToUpdate = 100; // Example amount to add to the balance
        const txUpdateBalance = await normalMedium.updateBalance(addressToAdd, amountToUpdate); // Updating balance
        const receiptUpdateBalance = await txUpdateBalance.wait(); // Wait for the transaction to be mined
        console.log(`Gas used for updateBalance(${addressToAdd}, ${amountToUpdate}) in instance ${i}:`, receiptUpdateBalance.gasUsed.toString());

        // Retrieve data by invoking retrieveData function
        const [data, name, addresses, totalAddresses] = await normalMedium.retrieveData();
        console.log(`Data retrieved from instance ${i}:`, data.toString(), `Name: ${name}, Addresses: ${addresses}, Total Addresses: ${totalAddresses}`);

        // Get address balance by invoking getAddressBalance function
        const addressBalance = await normalMedium.getAddressBalance(addressToAdd);
        console.log(`Balance for address ${addressToAdd} in instance ${i}:`, addressBalance.toString());
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

