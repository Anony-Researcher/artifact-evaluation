// SPDX-License-Identifier: MIT
/**
 * https://twitter.com/CommunityShido
 * https://t.me/CommunityShido
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
            uint256 buyFee,
            uint256 sellFee,
            uint256 maxTxAmount,
            uint256 maxWalletSize,
            uint256 taxSwapThreshold,
            uint256 maxTaxSwap
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (
            ds._taxForBuys,
            ds._taxForSells,
            ds._txAmountLmt,
            ds._walletAmountLmt,
            ds._swapbackMin,
            ds._swapbackMax
        );
    }
}
