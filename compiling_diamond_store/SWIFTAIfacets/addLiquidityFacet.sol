// SPDX-License-Identifier: MIT

/*

.................................................................
..####...##...##..######..######..######...........####...######.
.##......##...##....##....##........##............##..##....##...
..####...##.#.##....##....####......##............######....##...
.....##..#######....##....##........##............##..##....##...
..####....##.##...######..##........##............##..##..######.
.................................................................
                                                                     
 Telegram: https://t.me/SwiftAIB
 Twitter: https://x.com/swift_aitoken?s=21
 Website: https://swiftaibot.com/
 SwiftAI: https://t.me/SwiftAIIBOT

*/

pragma solidity 0.8.22;
import "./TestLib.sol";
contract addLiquidityFacet is ERC20 {
    using Address for address payable;

    modifier lockSwapping() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }
    modifier inSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds.swapping) {
            ds.swapping = true;
            _;
            ds.swapping = false;
        }
    }

    function addLiquidity(uint256 tokenAmount, uint256 bnbAmount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // approve token transfer to cover all possible scenarios
        _approve(address(this), address(ds.router), tokenAmount);

        // add the liquidity
        ds.router.addLiquidityETH{value: bnbAmount}(
            address(this),
            tokenAmount,
            0, // slippage is unavoidable
            0, // slippage is unavoidable
            address(0xdead),
            block.timestamp
        );
    }
}
