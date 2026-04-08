/*
 * SPDX-License-Identifier: MIT
 * https://twitter.com/FrogcoinOnEth
 * https://t.me/FROG_COIN_ETH
 * https://frogcoineth.vip/
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract viewValuesFacet is ERC20 {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function viewValues()
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
            ds._buyTax,
            ds._sellTax,
            ds._maxTx,
            ds._maxHold,
            ds._lowerSwapbackAmount,
            ds._upperSwapbackAmount
        );
    }
}
