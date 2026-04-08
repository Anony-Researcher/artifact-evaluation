//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./TestLib.sol";
contract SetTradeBalancePERCENTFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner, "Ownable: caller is not the owner");
        _;
    }

    function SetTradeBalancePERCENT(uint256 _tradingBalanceInTokens) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.tradingBalanceInTokens = _tradingBalanceInTokens;
    }
}
