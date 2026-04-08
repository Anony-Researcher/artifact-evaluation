/*
 * SPDX-License-Identifier: MIT
 * https://hobbestoken.vip
 * https://twitter.com/HobbesOnEth
 * https://t.me/Hobbes_Eth
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract checkMappingsFacet is ERC20 {
    using SafeMath for uint256;

    function checkMappings(
        address _target
    )
        external
        view
        returns (
            bool _isFeeExempt,
            bool _isTxLimitExempt,
            bool _automatedMarketMakerPairs
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _isFeeExempt = ds.isFeeExempt[_target];
        _isTxLimitExempt = ds.isTxLimitExempt[_target];
        _automatedMarketMakerPairs = ds.automatedMarketMakerPairs[_target];
    }
}
