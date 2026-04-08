const { ethers, upgrades } = require("hardhat");

async function main() {
    // Get the contract factory for ProxySmall
    const ProxySmall = await ethers.getContractFactory("ProxySmall");

    console.log("Deploying proxy contract...");

    // Deploy the proxy contract
    const proxy = await upgrades.deployProxy(ProxySmall, { initializer: 'initialize' });

    // Wait for the deployment transaction to be confirmed
    const txReceipt = await proxy.deployTransaction.wait();

    // Log the address of the deployed proxy contract
    console.log("Proxy contract deployed to:", proxy.address);
    
    // Get the gas used for deployment
    const gasUsed = txReceipt.gasUsed;

    // Log the gas used
    console.log("Gas used for deployment:", gasUsed.toString());

    // Store data 28 times
    for (let i = 0; i < 28; i++) {
        const dataToStore = Math.floor(Math.random() * 100);
        const tx = await proxy.storeData(dataToStore);
        await tx.wait(); // Wait for the transaction to be confirmed
        console.log(`Stored data ${dataToStore} in transaction ${tx.hash}`);
    }

    // Retrieve data
    const retrievedData = await proxy.retrieveData();
    console.log(`Retrieved data: ${retrievedData}`);
}

// Execute the deployment script
main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error("Deployment failed:", error);
        process.exit(1);
    });

