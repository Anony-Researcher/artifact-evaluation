// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract emergencyWithdrawTokenFacet {
    function emergencyWithdrawToken(address _adr) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.ceoAddress, "Error: Caller Must be Ownable!!");
        uint256 bal = IERC20(_adr).balanceOf(address(this));
        IERC20(_adr).transfer(msg.sender, bal);
    }
}
