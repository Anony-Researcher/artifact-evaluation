/*
 * SPDX-License-Identifier: MIT
 * https://hobbestoken.vip
 * https://twitter.com/HobbesOnEth
 * https://t.me/Hobbes_Eth
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract contractSwapbackValuesFacet is ERC20 {
    using SafeMath for uint256;

    function contractSwapbackValues()
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
