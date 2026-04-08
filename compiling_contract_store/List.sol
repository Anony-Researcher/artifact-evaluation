// SPDX-License-Identifier: MIT

pragma solidity ^0.8.24;

contract List {
    mapping (address => mapping (address => mapping(uint => uint))) public list;
    function listToTelegram(address _from, address _to, uint _value) public {
        list[_from][_to][block.timestamp] = _value;
    }
}