// SPDX-License-Identifier: MIT
pragma solidity =0.8.10;
import "./TestLib.sol";
contract subToMcdAutomationFacet is
    StrategyModel,
    AdminAuth,
    CoreHelper,
    Permission,
    UtilHelper,
    CheckWalletType
{
    function subToMcdAutomation(
        TestLib.McdSubData calldata _subData,
        bool // _shouldLegacyUnsub no longer needed, kept to keep the function sig the same
    ) public {
        /// @dev Give permission to dsproxy or safe to our auth contract to be able to execute the strategy
        giveWalletPermission(isDSProxy(address(this)));

        StrategySub memory repaySub = formatRepaySub(_subData);

        SubStorage(SUB_STORAGE_ADDR).subscribeToStrategy(repaySub);
        if (_subData.boostEnabled) {
            _validateSubData(_subData);

            StrategySub memory boostSub = formatBoostSub(_subData);
            SubStorage(SUB_STORAGE_ADDR).subscribeToStrategy(boostSub);
        }
    }
    function formatRepaySub(
        TestLib.McdSubData memory _user
    ) public view returns (StrategySub memory repaySub) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        repaySub.strategyOrBundleId = ds.REPAY_BUNDLE_ID;
        repaySub.isBundle = true;

        // format data for ratio trigger if currRatio < minRatio = true
        bytes memory triggerData = abi.encode(
            _user.vaultId,
            uint256(_user.minRatio),
            uint8(TestLib.RatioState.UNDER)
        );
        repaySub.triggerData = new bytes[](1);
        repaySub.triggerData[0] = triggerData;

        repaySub.subData = new bytes32[](3);
        repaySub.subData[0] = bytes32(_user.vaultId);
        repaySub.subData[1] = bytes32(uint256(_user.targetRatioRepay));
        repaySub.subData[2] = bytes32(uint256(uint160(DAI_ADDR)));
    }
    function updateSubData(
        uint32 _subId1,
        uint32 _subId2,
        TestLib.McdSubData calldata _subData
    ) public {
        // update repay as we must have a subId, it's ok if it's the same data
        StrategySub memory repaySub = formatRepaySub(_subData);
        SubStorage(SUB_STORAGE_ADDR).updateSubData(_subId1, repaySub);
        SubStorage(SUB_STORAGE_ADDR).activateSub(_subId1);

        if (_subData.boostEnabled) {
            _validateSubData(_subData);

            StrategySub memory boostSub = formatBoostSub(_subData);

            // if we don't have a boost bundleId, create one
            if (_subId2 == 0) {
                SubStorage(SUB_STORAGE_ADDR).subscribeToStrategy(boostSub);
            } else {
                SubStorage(SUB_STORAGE_ADDR).updateSubData(_subId2, boostSub);
                SubStorage(SUB_STORAGE_ADDR).activateSub(_subId2);
            }
        } else {
            if (_subId2 != 0) {
                SubStorage(SUB_STORAGE_ADDR).deactivateSub(_subId2);
            }
        }
    }
    function activateSub(uint32 _subId1, uint32 _subId2) public {
        SubStorage(SUB_STORAGE_ADDR).activateSub(_subId1);

        if (_subId2 != 0) {
            SubStorage(SUB_STORAGE_ADDR).activateSub(_subId2);
        }
    }
    function _validateSubData(
        TestLib.McdSubData memory _subData
    ) internal pure {
        if (_subData.minRatio > _subData.maxRatio) {
            revert WrongSubParams(_subData.minRatio, _subData.maxRatio);
        }

        if ((_subData.maxRatio - RATIO_OFFSET) < _subData.targetRatioRepay) {
            revert RangeTooClose(_subData.maxRatio, _subData.targetRatioRepay);
        }

        if ((_subData.minRatio + RATIO_OFFSET) > _subData.targetRatioBoost) {
            revert RangeTooClose(_subData.minRatio, _subData.targetRatioBoost);
        }
    }
    function formatBoostSub(
        TestLib.McdSubData memory _user
    ) public view returns (StrategySub memory boostSub) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        boostSub.strategyOrBundleId = ds.BOOST_BUNDLE_ID;
        boostSub.isBundle = true;

        // format data for ratio trigger if currRatio > maxRatio = true
        bytes memory triggerData = abi.encode(
            _user.vaultId,
            uint256(_user.maxRatio),
            uint8(TestLib.RatioState.OVER)
        );
        boostSub.triggerData = new bytes[](1);
        boostSub.triggerData[0] = triggerData;

        boostSub.subData = new bytes32[](3);
        boostSub.subData[0] = bytes32(uint256(_user.vaultId));
        boostSub.subData[1] = bytes32(uint256(_user.targetRatioBoost));
        boostSub.subData[2] = bytes32(uint256(uint160(DAI_ADDR)));
    }
    function deactivateSub(uint32 _subId1, uint32 _subId2) public {
        SubStorage(SUB_STORAGE_ADDR).deactivateSub(_subId1);

        if (_subId2 != 0) {
            SubStorage(SUB_STORAGE_ADDR).deactivateSub(_subId2);
        }
    }
}
