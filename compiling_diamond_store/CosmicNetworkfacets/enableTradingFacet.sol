// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract enableTradingFacet is ERC20, Ownable {
    using SafeMath for uint256;

    function enableTrading() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(tx.origin == owner(), "Only owner can enable trading");
        ds.bTradingActive = true;
        ds.bSwapEnabled = true;
    }
}
