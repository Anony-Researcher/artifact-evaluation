// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/proxy/utils/Initializable.sol";

contract ProxySmall is Initializable {
    uint256 public data;

    function initialize() public initializer {
        data = 0; // Initialize the data
    }

    function storeData(uint256 _data) public {
        data = _data;
    }

    function retrieveData() public view returns (uint256) {
        return data;
    }
}

