// Project Telegram: https://t.me/AllianceNetwork

// Contract has been created by <DEVAI> a Telegram AI bot. Visit https://t.me/ContractDevAI

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract antiWhaleInfoFacet is ERC20 {
    using SafeMath for uint256;

    function antiWhaleInfo()
        external
        view
        returns (
            bool _limitsInEffect,
            bool _trasnferDelayEnabled,
            uint256 _maxWallet,
            uint256 _maxTx
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _limitsInEffect = ds.limitsInEffect;

        _trasnferDelayEnabled = ds.trasnferDelayEnabled;

        _maxWallet = ds.maxWallet;

        _maxTx = ds.maxTx;
    }
}
