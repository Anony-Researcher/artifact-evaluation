// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity 0.8.20;
import "./TestLib.sol";
contract getAmmGovernancePoolConfigurationFacet is
    IAmmGovernanceLens,
    IAmmGovernanceService
{
    using IporContractValidator for address;
    using SafeERC20Upgradeable for IERC20Upgradeable;

    modifier onlySupportedAssetManagement(address asset) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (asset == ds._stEth || asset == ds._weEth) {
            revert IporErrors.UnsupportedModule(
                IporErrors.UNSUPPORTED_MODULE_ASSET_MANAGEMENT,
                asset
            );
        }
        _;
    }

    function getAmmGovernancePoolConfiguration(
        address asset
    ) external view override returns (AmmGovernancePoolConfiguration memory) {
        return _getPoolConfiguration(asset);
    }
    function depositToAssetManagement(
        address asset,
        uint256 wadAssetAmount
    ) external override onlySupportedAssetManagement(asset) {
        IAmmTreasury(_getAmmTreasury(asset)).depositToAssetManagementInternal(
            wadAssetAmount
        );
    }
    function withdrawFromAssetManagement(
        address asset,
        uint256 wadAssetAmount
    ) external override onlySupportedAssetManagement(asset) {
        IAmmTreasury(_getAmmTreasury(asset))
            .withdrawFromAssetManagementInternal(wadAssetAmount);
    }
    function withdrawAllFromAssetManagement(
        address asset
    ) external override onlySupportedAssetManagement(asset) {
        IAmmTreasury(_getAmmTreasury(asset))
            .withdrawAllFromAssetManagementInternal();
    }
    function transferToTreasury(
        address asset,
        uint256 wadAssetAmountInput
    ) external override {
        AmmGovernancePoolConfiguration memory poolCfg = _getPoolConfiguration(
            asset
        );

        require(
            msg.sender == poolCfg.ammPoolsTreasuryManager,
            AmmPoolsErrors.CALLER_NOT_TREASURY_MANAGER
        );

        uint256 assetAmountAssetDecimals = IporMath.convertWadToAssetDecimals(
            wadAssetAmountInput,
            poolCfg.decimals
        );
        uint256 wadAssetAmount = IporMath.convertToWad(
            assetAmountAssetDecimals,
            poolCfg.decimals
        );

        IAmmStorage(poolCfg.ammStorage)
            .updateStorageWhenTransferToTreasuryInternal(wadAssetAmount);

        IERC20Upgradeable(asset).safeTransferFrom(
            poolCfg.ammTreasury,
            poolCfg.ammPoolsTreasury,
            assetAmountAssetDecimals
        );
    }
    function transferToCharlieTreasury(
        address asset,
        uint256 wadAssetAmountInput
    ) external override {
        AmmGovernancePoolConfiguration memory poolCfg = _getPoolConfiguration(
            asset
        );

        require(
            msg.sender == poolCfg.ammCharlieTreasuryManager,
            AmmPoolsErrors.CALLER_NOT_PUBLICATION_FEE_TRANSFERER
        );

        uint256 assetAmountAssetDecimals = IporMath.convertWadToAssetDecimals(
            wadAssetAmountInput,
            poolCfg.decimals
        );
        uint256 wadAssetAmount = IporMath.convertToWad(
            assetAmountAssetDecimals,
            poolCfg.decimals
        );

        IAmmStorage(poolCfg.ammStorage)
            .updateStorageWhenTransferToCharlieTreasuryInternal(wadAssetAmount);

        IERC20Upgradeable(asset).safeTransferFrom(
            poolCfg.ammTreasury,
            poolCfg.ammCharlieTreasury,
            assetAmountAssetDecimals
        );
    }
    function addSwapLiquidator(
        address asset,
        address account
    ) external override {
        AmmConfigurationManager.addSwapLiquidator(asset, account);
    }
    function removeSwapLiquidator(
        address asset,
        address account
    ) external override {
        AmmConfigurationManager.removeSwapLiquidator(asset, account);
    }
    function isSwapLiquidator(
        address asset,
        address account
    ) external view override returns (bool) {
        return AmmConfigurationManager.isSwapLiquidator(asset, account);
    }
    function addAppointedToRebalanceInAmm(
        address asset,
        address account
    ) external override onlySupportedAssetManagement(asset) {
        AmmConfigurationManager.addAppointedToRebalanceInAmm(asset, account);
    }
    function removeAppointedToRebalanceInAmm(
        address asset,
        address account
    ) external override onlySupportedAssetManagement(asset) {
        AmmConfigurationManager.removeAppointedToRebalanceInAmm(asset, account);
    }
    function isAppointedToRebalanceInAmm(
        address asset,
        address account
    ) external view override returns (bool) {
        return
            AmmConfigurationManager.isAppointedToRebalanceInAmm(asset, account);
    }
    function setAmmPoolsParams(
        address asset,
        uint32 newMaxLiquidityPoolBalance,
        uint32 newAutoRebalanceThreshold,
        uint16 newAmmTreasuryAndAssetManagementRatio
    ) external override {
        AmmConfigurationManager.setAmmPoolsParams(
            asset,
            newMaxLiquidityPoolBalance,
            newAutoRebalanceThreshold,
            newAmmTreasuryAndAssetManagementRatio
        );
    }
    function getAmmPoolsParams(
        address asset
    ) external view override returns (AmmPoolsParamsConfiguration memory cfg) {
        StorageLib.AmmPoolsParamsValue
            memory ammPoolsParamsCfg = AmmConfigurationManager
                .getAmmPoolsParams(asset);
        cfg = AmmPoolsParamsConfiguration({
            maxLiquidityPoolBalance: uint256(
                ammPoolsParamsCfg.maxLiquidityPoolBalance
            ) * 1e18,
            autoRebalanceThresholdInThousands: ammPoolsParamsCfg
                .autoRebalanceThresholdInThousands,
            ammTreasuryAndAssetManagementRatio: ammPoolsParamsCfg
                .ammTreasuryAndAssetManagementRatio
        });
    }
    function _getPoolConfiguration(
        address asset
    ) internal view returns (AmmGovernancePoolConfiguration memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (asset == ds._usdt) {
            return
                AmmGovernancePoolConfiguration({
                    asset: ds._usdt,
                    decimals: ds._usdtDecimals,
                    ammStorage: ds._usdtAmmStorage,
                    ammTreasury: ds._usdtAmmTreasury,
                    ammPoolsTreasury: ds._usdtAmmPoolsTreasury,
                    ammPoolsTreasuryManager: ds._usdtAmmPoolsTreasuryManager,
                    ammCharlieTreasury: ds._usdtAmmCharlieTreasury,
                    ammCharlieTreasuryManager: ds._usdtAmmCharlieTreasuryManager
                });
        } else if (asset == ds._usdc) {
            return
                AmmGovernancePoolConfiguration({
                    asset: ds._usdc,
                    decimals: ds._usdcDecimals,
                    ammStorage: ds._usdcAmmStorage,
                    ammTreasury: ds._usdcAmmTreasury,
                    ammPoolsTreasury: ds._usdcAmmPoolsTreasury,
                    ammPoolsTreasuryManager: ds._usdcAmmPoolsTreasuryManager,
                    ammCharlieTreasury: ds._usdcAmmCharlieTreasury,
                    ammCharlieTreasuryManager: ds._usdcAmmCharlieTreasuryManager
                });
        } else if (asset == ds._dai) {
            return
                AmmGovernancePoolConfiguration({
                    asset: ds._dai,
                    decimals: ds._daiDecimals,
                    ammStorage: ds._daiAmmStorage,
                    ammTreasury: ds._daiAmmTreasury,
                    ammPoolsTreasury: ds._daiAmmPoolsTreasury,
                    ammPoolsTreasuryManager: ds._daiAmmPoolsTreasuryManager,
                    ammCharlieTreasury: ds._daiAmmCharlieTreasury,
                    ammCharlieTreasuryManager: ds._daiAmmCharlieTreasuryManager
                });
        } else if (asset == ds._stEth) {
            return
                AmmGovernancePoolConfiguration({
                    asset: ds._stEth,
                    decimals: ds._stEthDecimals,
                    ammStorage: ds._stEthAmmStorage,
                    ammTreasury: ds._stEthAmmTreasury,
                    ammPoolsTreasury: ds._stEthAmmPoolsTreasury,
                    ammPoolsTreasuryManager: ds._stEthAmmPoolsTreasuryManager,
                    ammCharlieTreasury: ds._stEthAmmCharlieTreasury,
                    ammCharlieTreasuryManager: ds
                        ._stEthAmmCharlieTreasuryManager
                });
        } else if (asset == ds._weEth) {
            return
                AmmGovernancePoolConfiguration({
                    asset: ds._weEth,
                    decimals: ds._weEthDecimals,
                    ammStorage: ds._weEthAmmStorage,
                    ammTreasury: ds._weEthAmmTreasury,
                    ammPoolsTreasury: ds._weEthAmmPoolsTreasury,
                    ammPoolsTreasuryManager: ds._weEthAmmPoolsTreasuryManager,
                    ammCharlieTreasury: ds._weEthAmmCharlieTreasury,
                    ammCharlieTreasuryManager: ds
                        ._weEthAmmCharlieTreasuryManager
                });
        } else {
            revert(IporErrors.ASSET_NOT_SUPPORTED);
        }
    }
    function _getAmmTreasury(address asset) internal view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (asset == ds._usdt) {
            return ds._usdtAmmTreasury;
        } else if (asset == ds._usdc) {
            return ds._usdcAmmTreasury;
        } else if (asset == ds._dai) {
            return ds._daiAmmTreasury;
        } else if (asset == ds._stEth) {
            return ds._stEthAmmTreasury;
        } else if (asset == ds._weEth) {
            return ds._weEthAmmTreasury;
        } else {
            revert(IporErrors.ASSET_NOT_SUPPORTED);
        }
    }
}
