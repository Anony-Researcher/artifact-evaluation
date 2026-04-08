// SPDX-License-Identifier: MIT
// Telegram: https://t.me/zerogastoken
pragma solidity ^0.8.25;
import "./TestLib.sol";
contract addLiquidityFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Ownable: caller is not the ds.owner");
        _;
    }

    function addLiquidity() public payable {}
}
