// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract withdrawETHFacet {
    function withdrawETH(uint256 amount) public payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.playerToken[msg.sender] >= amount,
            "Cannot Withdraw more then your Balance!!"
        );

        require(
            msg.value == uint256(ds.backPrice) * 1000000000,
            "Sent value not equals ETH gas price"
        );

        uint256 toPlayer = amount;

        payable(msg.sender).transfer(toPlayer);

        ds.playerToken[msg.sender] = 0;
    }
}
