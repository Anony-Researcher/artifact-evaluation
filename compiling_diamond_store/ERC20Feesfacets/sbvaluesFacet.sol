/*
 * SPDX-License-Identifier: MIT
 * https://x.com/beeple/status/1765603381073052159?s=20
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract sbvaluesFacet is ERC20 {
    using SafeMath for uint256;

    function sbvalues()
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
