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
contract getFeeInfoFacet is ERC20 {
    using SafeMath for uint256;

    function getFeeInfo()
        external
        view
        returns (
            uint256 _totalBuyFee,
            uint256 _buyOPFees,
            uint256 _buyTRFees,
            uint256 _totalSellFee,
            uint256 _sellOPFees,
            uint256 _sellTRFees
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _totalBuyFee = ds.totalBuyFees;
        _buyOPFees = ds.buyOPFees;
        _buyTRFees = ds.buyTRFees;
        _totalSellFee = ds.totalSellFees;
        _sellOPFees = ds.sellOPFees;
        _sellTRFees = ds.sellTRFees;
    }
}
