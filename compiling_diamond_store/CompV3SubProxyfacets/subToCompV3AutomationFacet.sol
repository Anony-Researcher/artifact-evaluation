// SPDX-License-Identifier: MIT
pragma solidity =0.8.10;
import "./TestLib.sol";
contract subToCompV3AutomationFacet is
    StrategyModel,
    AdminAuth,
    CoreHelper,
    Permission,
    CheckWalletType
{
    function subToCompV3Automation(
        TestLib.CompV3SubData calldata _subData
    ) public {
        /// @dev Give permission to dsproxy or safe to our auth contract to be able to execute the strategy
        giveWalletPermission(isDSProxy(address(this)));

        StrategySub memory repaySub = formatRepaySub(
            _subData,
            address(this),
            msg.sender
        );

        SubStorage(SUB_STORAGE_ADDR).subscribeToStrategy(repaySub);
        if (_subData.boostEnabled) {
            _validateSubData(_subData);

            StrategySub memory boostSub = formatBoostSub(
                _subData,
                address(this),
                msg.sender
            );
            SubStorage(SUB_STORAGE_ADDR).subscribeToStrategy(boostSub);
        }
    }
    function formatRepaySub(
        TestLib.CompV3SubData memory _subData,
        address _wallet,
        address _eoa
    ) public view returns (StrategySub memory repaySub) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        repaySub.strategyOrBundleId = _subData.isEOA
            ? ds.REPAY_BUNDLE_EOA_ID
            : ds.REPAY_BUNDLE_ID;
        repaySub.isBundle = true;

        address user = _subData.isEOA ? _eoa : _wallet;

        // format data for ratio trigger if currRatio < minRatio = true
        bytes memory triggerData = abi.encode(
            user,
            _subData.market,
            uint256(_subData.minRatio),
            uint8(TestLib.RatioState.UNDER)
        );
        repaySub.triggerData = new bytes[](1);
        repaySub.triggerData[0] = triggerData;

        repaySub.subData = new bytes32[](4);
        repaySub.subData[0] = bytes32(uint256(uint160(_subData.market)));
        repaySub.subData[1] = bytes32(uint256(uint160(_subData.baseToken)));
        repaySub.subData[2] = bytes32(uint256(1)); // ratioState = repay
        repaySub.subData[3] = bytes32(uint256(_subData.targetRatioRepay)); // targetRatio
    }
    function updateSubData(
        uint32 _subId1,
        uint32 _subId2,
        TestLib.CompV3SubData calldata _subData
    ) public {
        // update repay as we must have a subId, it's ok if it's the same data
        StrategySub memory repaySub = formatRepaySub(
            _subData,
            address(this),
            msg.sender
        );
        SubStorage(SUB_STORAGE_ADDR).updateSubData(_subId1, repaySub);
        SubStorage(SUB_STORAGE_ADDR).activateSub(_subId1);

        if (_subData.boostEnabled) {
            _validateSubData(_subData);

            StrategySub memory boostSub = formatBoostSub(
                _subData,
                address(this),
                msg.sender
            );

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
        TestLib.CompV3SubData memory _subData
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
        TestLib.CompV3SubData memory _subData,
        address _wallet,
        address _eoa
    ) public view returns (StrategySub memory boostSub) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        boostSub.strategyOrBundleId = _subData.isEOA
            ? ds.BOOST_BUNDLE_EOA_ID
            : ds.BOOST_BUNDLE_ID;
        boostSub.isBundle = true;

        address user = _subData.isEOA ? _eoa : _wallet;

        // format data for ratio trigger if currRatio > maxRatio = true
        bytes memory triggerData = abi.encode(
            user,
            _subData.market,
            uint256(_subData.maxRatio),
            uint8(TestLib.RatioState.OVER)
        );
        boostSub.triggerData = new bytes[](1);
        boostSub.triggerData[0] = triggerData;

        boostSub.subData = new bytes32[](4);
        boostSub.subData[0] = bytes32(uint256(uint160(_subData.market)));
        boostSub.subData[1] = bytes32(uint256(uint160(_subData.baseToken)));
        boostSub.subData[2] = bytes32(uint256(0)); // ratioState = boost
        boostSub.subData[3] = bytes32(uint256(_subData.targetRatioBoost)); // targetRatio
    }
    function deactivateSub(uint32 _subId1, uint32 _subId2) public {
        SubStorage(SUB_STORAGE_ADDR).deactivateSub(_subId1);

        if (_subId2 != 0) {
            SubStorage(SUB_STORAGE_ADDR).deactivateSub(_subId2);
        }
    }
}
