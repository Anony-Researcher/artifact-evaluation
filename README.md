# README

Overview

This repository presents an automated framework for converting standard Solidity smart contracts into the Diamond Standard (EIP-2535) architecture.

The system consists of two key components:

Auto-Convert Engine: Automatically transforms a regular smart contract into a diamond-based implementation.
Arbiter (Suggestion Engine): An analysis module that provides recommendations to improve contract structure, modularity, and conversion success.

The framework aims to simplify the adoption of upgradeable smart contract patterns while preserving original functionality and enabling systematic evaluation.

## Auto-Convert Engine

The `auto-convert` module performs the transformation from a monolithic Solidity contract to a diamond-compliant architecture.

Features
- Extracts logic into facets
- Generates necessary diamond structure files
- Preserves functional behavior of the original contract

```bash
# Run from within the auto_convert directory
node auto-convert.js <input-contract> <output-directory>
```
## Example
```bash
# Run from within the auto_convert directory
node auto-convert.js ./auto_convert_tests/Example.sol ./auto_convert_tests/
```

## Arbiter (Suggestion Engine)

The `arbiter` module analyzes smart contracts and provides recommendations to improve their suitability for diamond conversion.

Purpose
- Identify structural issues in contracts
- Suggest improvements for modularization
- Assist in increasing conversion success rate

Components
- `arbiter_suggester/`
→ Generates recommendations based on contract structure
- `arbiter_summary/`
→ Produces summarized insights across multiple contracts
- `threshold3/`
→ Defines thresholds used for triggering recommendations

Role in the Framework

The Arbiter acts as an intelligent assistant, guiding developers before and during the conversion process. It complements the Auto-Convert engine by addressing cases where fully automated transformation may fail.


## Hardhat Setup

The `hardhat` module is used for testing, deployment, and gas evaluation of generated diamond contracts.

Features
- Deployment of diamond contracts
- Validation of successful conversion
- Gas usage measurement

Key Files
- `test/genericDeployTest.js`
→ Tests whether converted contracts deploy successfully
- `scripts/genericDeploy.js`
→ Deploys contracts and records gas usage
- `scripts/automation.js`
→ Automates large-scale deployment and evaluation

Configuration
Set the `facetsFolderPath` variable in:

- `test/genericDeployTest.js`, or
- `scripts/genericDeploy.js`

Example usage
```bash
# Run tests
npx hardhat test test/genericDeployTest.js

# Run deployment script
npx hardhat run scripts/genericDeploy.js
```

## Experiments
This repository includes a large-scale empirical evaluation of the proposed framework.

- `processed_v5(7024contracts)/`
→ Collection of processed smart contracts used in experiments
- `compiling_contract_store/`
→ Contracts that successfully compile
- `compiling_diamond_store/`
→ Diamond-transformed versions of the above contracts

## Results
- `experiment_output/gas_comparison_results.csv`
→ Contains deployment metrics and gas usage comparisons

## Utilities
- `parse.js`
→ Parses Solidity contracts for analysis and transformation
- `visualize_contract.js`
→ Provides structural visualization of contracts