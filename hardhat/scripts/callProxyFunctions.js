// scripts/callProxyFunctions.js
const { ethers, upgrades } = require("hardhat");

async function main() {
    const proxyAddress = "YOUR_PROXY_CONTRACT_ADDRESS"; // Replace with your deployed proxy contract address
    const ProxySmall = await ethers.getContractFactory("ProxySmall");
    const proxySmallProxy = ProxySmall.attach(proxyAddress);

    for (let i = 1; i <= 28; i++) {
        const dataToStore = Math.floor(Math.random() * 100); // Random number between 0-99

        // Store data
        const txStore = await proxySmallProxy.storeData(dataToStore);
        const receiptStore = await txStore.wait();
        console.log(`Gas used for storeData(${dataToStore}) in instance ${i}:`, receiptStore.gasUsed.toString());

        // Retrieve data
        const dataRetrieved = await proxySmallProxy.retrieveData();
        console.log(`Data retrieved from instance ${i}:`, dataRetrieved.toString());
    }
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });

