// SPDX-License-Identifier: MIT

// $DESK

// Ultimate OTC DEX for trading airdrop allocations, brc20 tokens and ordinals.

// https://twitter.com/diamonddeskotc

// https://t.me/diamonddeskotc

// https://www.diamonddesk.io

pragma solidity 0.8.20;
import "./TestLib.sol";
contract rescueETHFacet is ERC20 {
    using Address for address payable;

    modifier inSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds.swapping) {
            ds.swapping = true;
            _;
            ds.swapping = false;
        }
    }

    function rescueETH(uint256 weiAmount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        payable(ds.marketingWallet).sendValue(weiAmount);
    }
}
