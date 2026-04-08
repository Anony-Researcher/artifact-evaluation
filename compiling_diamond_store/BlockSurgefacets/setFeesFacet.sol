/*

    Telegram: https://t.me/BlockSurgePortal
    Website: https://blocksurge.net
    X: https://x.com/BlockSurge_ERC

**/

// SPDX-License-Identifier: unlicense

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract setFeesFacet {
    function setFees(uint256 _buy, uint256 _sell) external {
        if (msg.sender != deployer) revert Permissions();
        _setFees(_buy, _sell);
    }
    function _setFees(uint256 _buy, uint256 _sell) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.buyTax = _buy;
        ds.sellTax = _sell;
        require(ds.buyTax < 50);
        require(ds.sellTax < 70);
    }
}
