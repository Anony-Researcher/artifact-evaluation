// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

library Helper {
    function calculate(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
}

contract Parent {
    uint256 public data;
    event DataStored(uint256 indexed data);

    function storeData(uint256 _data) public {
        data = _data;
        emit DataStored(data);
    }
}

contract NormalLarge is Parent {
    using Helper for uint256;

    function sendPayment(address payable _to) public payable {
        require(msg.value > 0, "Must send some Ether");
        _to.transfer(msg.value);
    }

    function compute(uint256 a, uint256 b) public pure returns (uint256) {
        return a.calculate(b);
    }
}

