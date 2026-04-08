/*
 * SPDX-License-Identifier: MIT
 * https://hobbestoken.vip
 * https://twitter.com/HobbesOnEth
 * https://t.me/Hobbes_Eth
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract trasactionLimitsFacet is ERC20 {
    using SafeMath for uint256;

    function trasactionLimits()
        external
        view
        returns (
            bool _limitsInEffect,
            bool _transferDelayEnabled,
            uint256 _maxWallet,
            uint256 _maxTx
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _limitsInEffect = ds.limitsInEffect;
        _transferDelayEnabled = ds.transferDelayEnabled;
        _maxWallet = ds.maxWallet;
        _maxTx = ds.maxTx;
    }
}
