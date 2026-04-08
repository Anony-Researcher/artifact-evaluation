// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract TrafficViolationData {
    struct Violation {
        string imageHash;
        string timestamp;
        string location;
    }

    Violation[] public violations;

    function storeViolation(string memory imageHash, string memory timestamp, string memory location) public {
        violations.push(Violation(imageHash, timestamp, location));
    }

    function getViolation(uint index) public view returns (string memory, string memory, string memory) {
        Violation memory v = violations[index];
        return (v.imageHash, v.timestamp, v.location);
    }
}

