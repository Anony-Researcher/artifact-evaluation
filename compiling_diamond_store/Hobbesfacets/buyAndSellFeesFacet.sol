/*
 * SPDX-License-Identifier: MIT
 * https://hobbestoken.vip
 * https://twitter.com/HobbesOnEth
 * https://t.me/Hobbes_Eth
 */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract buyAndSellFeesFacet is ERC20 {
    using SafeMath for uint256;

    function buyAndSellFees()
        external
        view
        returns (
            uint256 _totalBuyFee,
            uint256 _buyMktFee,
            uint256 _buyDevFee,
            uint256 _totalSellFee,
            uint256 _sellMktFee,
            uint256 _sellDevFee
        )
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        _totalBuyFee = ds.totalBuyFee;
        _buyMktFee = ds.buyMktFee;
        _buyDevFee = ds.buyDevFee;
        _totalSellFee = ds.totalSellFee;
        _sellMktFee = ds.sellMktFee;
        _sellDevFee = ds.sellDevFee;
    }
}
