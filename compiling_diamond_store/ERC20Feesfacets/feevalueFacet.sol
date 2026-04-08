/*
 * SPDX-License-Identifier: MIT
 * https://x.com/beeple/status/1765603381073052159?s=20
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract feevalueFacet is ERC20 {
    using SafeMath for uint256;

    function feevalue()
        external
        view
        returns (
            uint256 _totalbuy,
            uint256 _mktbuy,
            uint256 _devbuy,
            uint256 _totalsell,
            uint256 _mktsell,
            uint256 _devsell
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _totalbuy = ds.totalbuy;
        _mktbuy = ds.mktbuy;
        _devbuy = ds.devbuy;
        _totalsell = ds.totalsell;
        _mktsell = ds.mktsell;
        _devsell = ds.devsell;
    }
}
