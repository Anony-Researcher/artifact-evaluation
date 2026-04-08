// SPDX-License-Identifier: MIT

// $DESK

// Ultimate OTC DEX for trading airdrop allocations, brc20 tokens and ordinals.

// https://twitter.com/diamonddeskotc

// https://t.me/diamonddeskotc

// https://www.diamonddesk.io

pragma solidity 0.8.20;
import "./TestLib.sol";
contract rescueERC20Facet is ERC20 {
    using Address for address payable;

    modifier inSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds.swapping) {
            ds.swapping = true;
            _;
            ds.swapping = false;
        }
    }

    function rescueERC20(address tokenAddress, uint256 amount) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        IERC20(tokenAddress).transfer(ds.marketingWallet, amount);
    }
}
