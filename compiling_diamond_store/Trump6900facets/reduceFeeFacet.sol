// SPDX-License-Identifier: MIT

/*
Website: https://trump6900coin.com

Twitter: twitter.com/TAGAMemecoin

Telegram: https://t.me/TAGAPortal

Linktree: https://linktr.ee/TAGA6900

*/

pragma solidity 0.8.23;
import "./TestLib.sol";
contract reduceFeeFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function reduceFee(uint256 _newFeeBuy, uint256 _newFeeSell) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _newFeeBuy <= ds._initialBuyTax &&
                _newFeeSell <= ds._initialSellTax,
            "New fee must be less than or equal to initial fees"
        );
        ds._initialBuyTax = _newFeeBuy;
        ds._initialSellTax = _newFeeSell;
    }
}
