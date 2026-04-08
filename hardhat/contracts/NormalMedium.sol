// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract NormalMedium {
    uint256 public data;
    string public name;
    address[] public normalMediumAddresses;
    mapping(address => uint256) public addressBalances;
    uint256 public totalAddresses;

    function storeData(uint256 _data, string memory _name) public {
        data = _data;
        name = _name;
    }

    function addAddress(address _addr) public {
        normalMediumAddresses.push(_addr);
        addressBalances[_addr] = 0; // Initialize balance for the new address
        totalAddresses++;
    }

    function updateBalance(address _addr, uint256 _amount) public {
        require(addressBalances[_addr] + _amount >= addressBalances[_addr], "Overflow error");
        addressBalances[_addr] += _amount;
    }

    function retrieveData() public view returns (uint256, string memory, address[] memory, uint256) {
        return (data, name, normalMediumAddresses, totalAddresses);
    }

    function getAddressBalance(address _addr) public view returns (uint256) {
        return addressBalances[_addr];
    }
}

