// Project Telegram: https://t.me/AllianceNetwork

// Contract has been created by <DEVAI> a Telegram AI bot. Visit https://t.me/ContractDevAI

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract checkAddressPermissionsFacet is ERC20 {
    using SafeMath for uint256;

    function checkAddressPermissions(
        address _target
    )
        external
        view
        returns (
            bool _isFeeExempt,
            bool _isTxLimitExempt,
            bool _automatedMarketMakerPairs
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _isFeeExempt = ds.isFeeExempt[_target];

        _isTxLimitExempt = ds.isTxLimitExempt[_target];

        _automatedMarketMakerPairs = ds.automatedMarketMakerPairs[_target];
    }
}
