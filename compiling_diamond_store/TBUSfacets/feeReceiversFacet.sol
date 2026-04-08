// Project Telegram: https://t.me/AllianceNetwork

// Contract has been created by <DEVAI> a Telegram AI bot. Visit https://t.me/ContractDevAI

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract feeReceiversFacet is ERC20 {
    using SafeMath for uint256;

    function feeReceivers()
        external
        view
        returns (
            address _autoLPReceiver,
            address _mktReceiver,
            address _devReceiver
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (ds.autoLPReceiver, ds.mktReceiver, ds.devReceiver);
    }
}
