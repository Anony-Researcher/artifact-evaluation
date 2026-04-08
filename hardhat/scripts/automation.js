const fs = require('fs-extra');
const { run } = require('hardhat');
const path = require('path');
const { exec } = require('child_process');
const { deployDiamondWithFacets } = require('./genericDeploy');

function executeShellCommand(command) {
    return new Promise((resolve, reject) => {
        exec(command, (error, stdout, stderr) => {
            if (error) {
                reject(`Error: ${stderr || error.message}`);
            } else {
                console.log(stdout);
                resolve(stdout);
            }
        });
    });
}

async function compareGasUsage() {
    const diamondContractsDir = path.join(__dirname, '../../compiling_diamond_store');
    const hardhatOutputDir = path.join(__dirname, '../contracts/output');
    const outputDir = path.join(__dirname, '../../experiment_output');
    const csvFilePath = path.join(outputDir, 'gas_comparison_results.csv');
    const logFilePath = path.join(outputDir, 'processed_folders_log.json');

    // Create output directories if they don't exist
    if (!fs.existsSync(outputDir)) {
        fs.mkdirSync(outputDir);
    }
    if (!fs.existsSync(hardhatOutputDir)) {
        fs.mkdirSync(hardhatOutputDir);
    }

    // Initialize the processed folders log
    let processedFolders = new Set();

    // Load processed folders from the log file if it exists
    if (fs.existsSync(logFilePath)) {
        try {
            const data = fs.readFileSync(logFilePath, 'utf-8');
            processedFolders = new Set(JSON.parse(data));
        } catch (error) {
            console.error("Error reading log file:", error);
        }
    }

    // Add CSV header if the file doesn't exist
    if (!fs.existsSync(csvFilePath)) {
        const header = ['Contract Name', 'Status', 'Total Gas Used', 'Min Gas Cost for a Facet', 'Max Gas Cost for a Facet', 'Average Facet Gas Cost', 'Facet Gas Cost Stdev'];
        fs.writeFileSync(csvFilePath, header.join(',') + '\n');
    }

    // Iterate over folders in the diamond contracts directory
    for (const fileOrFolder of fs.readdirSync(diamondContractsDir)) {
        const fullPath = path.join(diamondContractsDir, fileOrFolder);

        // Check if the current path is a directory
        if (fs.lstatSync(fullPath).isDirectory()) {
            const match = fileOrFolder.match(/^(.*)facets$/);

            // If the folder name ends with 'facets', extract the contract name
            if (match) {
                const contractName = match[1];

                // Skip already processed folders
                if (processedFolders.has(contractName)) {
                    console.log(`Skipping already processed contract: ${contractName}`);
                    continue;
                }

                console.log(`Processing: ${contractName}`);
                const tmpOutputDir = path.join(hardhatOutputDir, `${contractName}facets`);

                // Create the temporary output directory if it doesn't exist
                if (!fs.existsSync(tmpOutputDir)) {
                    fs.mkdirSync(tmpOutputDir);
                }

                // Copy the contents of the folder to the temporary output directory
                await fs.copy(fullPath, tmpOutputDir);

                try {
                    await executeShellCommand(`npx hardhat compile`);
                    // Deploy the diamond and retrieve gas statistics
                    const { diamondAddress, gasStats, totalGasUsed } = await deployDiamondWithFacets(tmpOutputDir);

                    // Log the deployment details
                    console.log(`Diamond Address for ${contractName}: ${diamondAddress}`);
                    console.log(`Gas Usage Statistics for ${contractName}:`, gasStats);
                    console.log(`Total Gas Used for Deployment for ${contractName}: ${totalGasUsed.toString()}`);

                    // Add the successful deployment results to the CSV data
                    const row = [
                        contractName, 
                        'Success', 
                        totalGasUsed, 
                        gasStats.min, 
                        gasStats.max, 
                        gasStats.average, 
                        gasStats.stdev
                    ];
                    fs.appendFileSync(csvFilePath, row.join(',') + '\n');
                } catch (error) {
                    console.log(`Error when deploying contract ${contractName}:`, error);

                    // Add a failed status to the CSV data
                    const row = [contractName, 'Failed', 'NA', 'NA', 'NA', 'NA', 'NA'];
                    fs.appendFileSync(csvFilePath, row.join(',') + '\n');
                }

                // Remove the temporary output directory after processing
                if (fs.existsSync(tmpOutputDir)) {
                    fs.rmSync(tmpOutputDir, { recursive: true, force: true });
                    console.log(`Deleted diamond pattern output for ${contractName}`);
                }

                // Add the processed contract name to the log and save it
                processedFolders.add(contractName);
                fs.writeFileSync(logFilePath, JSON.stringify(Array.from(processedFolders), null, 2));
            } else {
                console.log(`No match for: ${fileOrFolder}`);
            }
        }
    }

    console.log(`Results saved to gas_comparison_results.csv in the output directory: ${csvFilePath}`);
}

compareGasUsage()
    .then(() => process.exit(0))
    .catch(error => {
        console.error("Script failed with an unexpected error:", error);
        process.exit(1);
    });