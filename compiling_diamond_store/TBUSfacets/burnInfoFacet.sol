// Project Telegram: https://t.me/AllianceNetwork

// Contract has been created by <DEVAI> a Telegram AI bot. Visit https://t.me/ContractDevAI

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract burnInfoFacet is ERC20 {
    using SafeMath for uint256;

    function burnInfo()
        external
        view
        returns (bool _burnEnabled, uint256 _lastSync)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _burnEnabled = ds.burnEnabled;

        _lastSync = ds.lastSync;
    }
}
