// File: @chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol
//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract depositTokenFacet {
    function depositToken(uint256 amount) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IERC20(ds.TokenAdr).transferFrom(msg.sender, address(this), amount);
    }
}
