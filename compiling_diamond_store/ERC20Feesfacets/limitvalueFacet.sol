/*
 * SPDX-License-Identifier: MIT
 * https://x.com/beeple/status/1765603381073052159?s=20
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract limitvalueFacet is ERC20 {
    using SafeMath for uint256;

    function limitvalue()
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
