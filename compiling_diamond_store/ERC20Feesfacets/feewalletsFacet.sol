/*
 * SPDX-License-Identifier: MIT
 * https://x.com/beeple/status/1765603381073052159?s=20
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract feewalletsFacet is ERC20 {
    using SafeMath for uint256;

    function feewallets()
        external
        view
        returns (address _mktfeereceiver, address _devfeereceiver)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (ds.mktfeereceiver, ds.devfeereceiver);
    }
}
