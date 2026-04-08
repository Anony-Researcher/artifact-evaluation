/*
 * SPDX-License-Identifier: MIT
 * https://marvininu.vip/
 * https://t.me/Marvin_inu_eth
 * https://twitter.com/marvin_inu_eth
 *  __       __   ______   _______   __     __  ______  __    __
 * /  \     /  | /      \ /       \ /  |   /  |/      |/  \  /  |
 * $$  \   /$$ |/$$$$$$  |$$$$$$$  |$$ |   $$ |$$$$$$/ $$  \ $$ |
 * $$$  \ /$$$ |$$ |__$$ |$$ |__$$ |$$ |   $$ |  $$ |  $$$  \$$ |
 * $$$$  /$$$$ |$$    $$ |$$    $$< $$  \ /$$/   $$ |  $$$$  $$ |
 * $$ $$ $$/$$ |$$$$$$$$ |$$$$$$$  | $$  /$$/    $$ |  $$ $$ $$ |
 * $$ |$$$/ $$ |$$ |  $$ |$$ |  $$ |  $$ $$/    _$$ |_ $$ |$$$$ |
 * $$ | $/  $$ |$$ |  $$ |$$ |  $$ |   $$$/    / $$   |$$ | $$$ |
 * $$/      $$/ $$/   $$/ $$/   $$/     $/     $$$$$$/ $$/   $$/
 *
 *  ______  __    __  __    __
 * /      |/  \  /  |/  |  /  |
 * $$$$$$/ $$  \ $$ |$$ |  $$ |
 *   $$ |  $$$  \$$ |$$ |  $$ |
 *   $$ |  $$$$  $$ |$$ |  $$ |
 *   $$ |  $$ $$ $$ |$$ |  $$ |
 *  _$$ |_ $$ |$$$$ |$$ \__$$ |
 * / $$   |$$ | $$$ |$$    $$/
 * $$$$$$/ $$/   $$/  $$$$$$/
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract viewInfoFacet is ERC20 {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function viewInfo()
        external
        view
        returns (
            uint256 _buyFee,
            uint256 _sellFee,
            uint256 maxTxAmount,
            uint256 maxWalletSize,
            uint256 taxSwapThreshold,
            uint256 maxTaxSwap
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (
            ds.buyFee,
            ds.sellFee,
            ds._txAmountLimit,
            ds._walletAmountLimit,
            ds._swapbackMin,
            ds._swapbackMax
        );
    }
}
