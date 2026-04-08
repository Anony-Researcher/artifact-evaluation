// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract balanceOfETHFacet {
    function balanceOfETH() external view returns (uint256) {
        return address(this).balance;
    }
}
