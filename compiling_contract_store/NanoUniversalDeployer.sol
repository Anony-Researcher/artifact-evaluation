//SPDX-License-Identifier: MIT
// Based on the work of 0xSequence/deployer

pragma solidity ^0.8.0;

contract NanoUniversalDeployer {
    event Deploy(address _addr) anonymous;

    fallback() external payable {
        address addr;
        bytes memory code = msg.data;
        assembly { addr := create2(callvalue(), add(code, 32), mload(code), 0) }
        emit Deploy(addr);
    }
}