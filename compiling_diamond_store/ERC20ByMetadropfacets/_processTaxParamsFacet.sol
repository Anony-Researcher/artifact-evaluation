//
//          Telegram (not verified): https://t.me/Pepe2ERC20
//          Website  (not verified): https://pepe2eth.vip
//
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// @@                                                                                                @@
// @@   This token was launched using software provided by Metadrop. To learn more or to launch      @@
// @@   your own token, visit: https://metadrop.com. See legal info at the end of this file.         @@
// @@                                                                                                @@
// @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//
// SPDX-License-Identifier: BUSL-1.1
// Metadrop Contracts (v2.1.0)
//

// Sources flattened with hardhat v2.17.2 https://hardhat.org

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.3

// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract _processTaxParamsFacet is Context {
    using EnumerableSet for EnumerableSet.AddressSet;
    using EnumerableSet for EnumerableSet.Bytes32Set;
    using SafeERC20 for IERC20;

    modifier onlyOwnerFactoryOrPool() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (
            ds.metadropFactory != _msgSender() &&
            owner() != _msgSender() &&
            ds.driPool != _msgSender()
        ) {
            _revert(CallerIsNotFactoryProjectOwnerOrPool.selector);
        }
        if (owner() == _msgSender() && ds.driPool != address(0)) {
            _revert(CannotManuallyFundLPWhenUsingADRIPool.selector);
        }

        _;
    }
    modifier notDuringAutoswap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._autoSwapInProgress) {
            _revert(CannotPerformDuringAutoswap.selector);
        }
        _;
    }

    function _processTaxParams(
        ERC20TaxParameters memory erc20TaxParameters_
    ) internal returns (bool tokenHasTax_) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        /**
         * @dev We use the immutable var {ds._tokenHasTax} to avoid unneccesary storage writes and reads. If this
         * token does NOT have tax applied then there is no need to store or read these parameters, and we can
         * avoid this simply by checking the immutable var. Pass back the value for this var from this method.
         */
        if (
            erc20TaxParameters_.ds.projectBuyTaxBasisPoints == 0 &&
            erc20TaxParameters_.ds.projectSellTaxBasisPoints == 0 &&
            erc20TaxParameters_.ds.metadropBuyTaxBasisPoints == 0 &&
            erc20TaxParameters_.ds.metadropSellTaxBasisPoints == 0
        ) {
            return false;
        } else {
            // Validate that the sum of all buy deductions does not equal or exceed
            // 10,000 basis points (i.e. 100%).
            if (
                (erc20TaxParameters_.ds.projectBuyTaxBasisPoints +
                    erc20TaxParameters_.ds.metadropBuyTaxBasisPoints +
                    erc20TaxParameters_.ds.autoBurnBasisPoints) >= BP_DENOM
            ) {
                _revert(DeductionsOnBuyExceedOrEqualOneHundredPercent.selector);
            }

            ds.projectBuyTaxBasisPoints = uint16(
                erc20TaxParameters_.ds.projectBuyTaxBasisPoints
            );
            ds.projectSellTaxBasisPoints = uint16(
                erc20TaxParameters_.ds.projectSellTaxBasisPoints
            );
            ds.metadropBuyTaxBasisPoints = uint16(
                erc20TaxParameters_.ds.metadropBuyTaxBasisPoints
            );
            ds.metadropSellTaxBasisPoints = uint16(
                erc20TaxParameters_.ds.metadropSellTaxBasisPoints
            );

            if (
                erc20TaxParameters_.taxSwapThresholdBasisPoints <
                MIN_AUTOSWAP_THRESHOLD_BP
            ) {
                _revert(SwapThresholdTooLow.selector);
            }

            ds.swapThresholdBasisPoints = uint16(
                erc20TaxParameters_.taxSwapThresholdBasisPoints
            );

            ds.projectTaxRecipient = erc20TaxParameters_.ds.projectTaxRecipient;
            return true;
        }
    }
}
