// Project Telegram: https://t.me/AllianceNetwork

// Contract has been created by <DEVAI> a Telegram AI bot. Visit https://t.me/ContractDevAI

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract swapbackInfoFacet is ERC20 {
    using SafeMath for uint256;

    function swapbackInfo()
        external
        view
        returns (
            bool _swapbackEnabled,
            uint256 _swapBackValueMin,
            uint256 _swapBackValueMax
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _swapbackEnabled = ds.swapbackEnabled;

        _swapBackValueMin = ds.swapBackValueMin;

        _swapBackValueMax = ds.swapBackValueMax;
    }
}
