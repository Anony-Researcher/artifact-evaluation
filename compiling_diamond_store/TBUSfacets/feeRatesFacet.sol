// Project Telegram: https://t.me/AllianceNetwork

// Contract has been created by <DEVAI> a Telegram AI bot. Visit https://t.me/ContractDevAI

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract feeRatesFacet is ERC20 {
    using SafeMath for uint256;

    function feeRates()
        external
        view
        returns (
            uint256 _totalBuyFee,
            uint256 _buyMktFee,
            uint256 _buyLPFee,
            uint256 _buyDevFee,
            uint256 _totalSellFee,
            uint256 _sellMktFee,
            uint256 _sellLpFee,
            uint256 _sellDevFee,
            uint256 _totalTransferFee,
            uint256 _transferMktFee,
            uint256 _transferLpFee,
            uint256 _transferDevFee
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _totalBuyFee = ds.totalBuyFee;

        _buyMktFee = ds.buyMktFee;

        _buyLPFee = ds.buyLPFee;

        _buyDevFee = ds.buyDevFee;

        _totalSellFee = ds.totalSellFee;

        _sellMktFee = ds.sellMktFee;

        _sellLpFee = ds.sellLpFee;

        _sellDevFee = ds.sellDevFee;

        _totalTransferFee = ds.totalTransferFee;

        _transferMktFee = ds.transferMktFee;

        _transferLpFee = ds.transferLpFee;

        _transferDevFee = ds.transferDevFee;
    }
}
