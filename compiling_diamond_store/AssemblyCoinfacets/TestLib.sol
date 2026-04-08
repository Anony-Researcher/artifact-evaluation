/*
    This Ethereum smart contract implements a simplified version of the ERC20 token standard,
    utilizing EVM (Ethereum Virtual Machine) inline assembly for critical sections to optimize
    gas costs and enhance performance.

    Inline assembly is used in this contract for the following reasons:
    1. Direct Access to Storage: By bypassing Solidity's abstraction layer, we can directly
       interact with EVM storage, allowing for more efficient reads and writes. This is
       particularly beneficial in functions like balanceOf, transfer, and transferFrom,
       where multiple storage operations are performed.
    2. Reduced Execution Cost: Assembly code is lower-level than Solidity and closer to the
       EVM's native instructions, meaning it often requires fewer computational steps. This
       can significantly reduce gas costs for frequent operations like transferring tokens
       and checking balances.
    3. Custom Logic Implementation: Assembly allows for more sophisticated control over
       the flow of execution than Solidity, enabling optimizations that are not possible
       in high-level code, such as custom inline checks and balances updates.

    However, it's important to note the following:
    - Inline assembly can be less readable and harder to audit than Solidity code. Therefore,
      it's used sparingly and only where significant optimizations are achievable.
    - The contract ensures that safety checks (e.g., ensuring addresses are non-zero, balances
      are sufficient) are still performed in Solidity to maintain code clarity and security.
    - Testing and security audits are critical when using assembly to prevent subtle bugs and
      vulnerabilities.

    By carefully integrating assembly code, this contract aims to offer the standard functionality
    of an ERC20 token while minimizing gas costs for end-users. This approach makes the token
    more efficient to use in the Ethereum network, potentially leading to higher adoption and
    user satisfaction.
*/
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        string name;
        string symbol;
        uint8 decimals;
        mapping(address => uint256) balances;
        mapping(address => mapping(address => uint256)) allowances;
        uint256 _totalSupply;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
