// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract changeCEOFacet {
    function changeCEO(address _adr) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.ceoAddress, "Error: Caller Must be Ownable!!");

        ds.ceoAddress = _adr;
    }
}
