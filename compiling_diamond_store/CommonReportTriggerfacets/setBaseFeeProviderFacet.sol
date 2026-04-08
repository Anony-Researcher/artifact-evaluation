// SPDX-License-Identifier: GPL-3.0
pragma solidity 0.8.18;
import "./TestLib.sol";
contract setBaseFeeProviderFacet is Governance {
    event NewBaseFeeProvider(address indexed provider);
    event UpdatedAcceptableBaseFee(uint256 acceptableBaseFee);
    function setBaseFeeProvider(
        address _baseFeeProvider
    ) external onlyGovernance {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.baseFeeProvider = _baseFeeProvider;

        emit NewBaseFeeProvider(_baseFeeProvider);
    }
    function setAcceptableBaseFee(
        uint256 _newAcceptableBaseFee
    ) external onlyGovernance {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.acceptableBaseFee = _newAcceptableBaseFee;

        emit UpdatedAcceptableBaseFee(_newAcceptableBaseFee);
    }
}
