/*

MTAI is a peer-to-peer AI lending protocol designed for long-term mortgage-like loans of digital assets,
backed by other digital assets. 
Borrowers can receive a fixed-duration loan of fungible tokens backed by fungible or non-fungible tokens, 
while lenders can earn interest by granting these loans. 
The protocol is trustless, immutable, operates without the need for oracles, 
and without protocol-managed liquidations.

    Website:       https://www.merittradingai.com

    Document:      https://docs.merittradingai.com

    Trading App:   https://trade.merittradingai.com

    Twitter:       https://twitter.com/merittradingai

    Telegram:      https://t.me/merittradingai

*/

/*
 * SPDX-License-Identifier: MIT
 */

pragma solidity 0.8.22;
import "./TestLib.sol";
contract getValuesFacet is ERC20 {
    using SafeMath for uint256;

    function getValues(
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
        _isFeeExempt = ds._isFeeExcludedFrom[_target];
        _isTxLimitExempt = ds._isTxExcludedFrom[_target];
        _automatedMarketMakerPairs = ds._ammPairs[_target];
    }
}
