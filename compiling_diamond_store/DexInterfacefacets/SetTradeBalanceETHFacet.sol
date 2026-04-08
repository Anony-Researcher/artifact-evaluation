//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./TestLib.sol";
contract SetTradeBalanceETHFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner, "Ownable: caller is not the owner");
        _;
    }

    function SetTradeBalanceETH(uint256 _tradingBalanceInPercent) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingBalanceInPercent = _tradingBalanceInPercent;
    }
}
