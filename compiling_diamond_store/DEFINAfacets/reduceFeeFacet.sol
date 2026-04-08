// SPDX-License-Identifier: MIT
/**
Bring honor to your guild and battle Vrykos’ to save humanity from the brink of destruction!

Website: https://www.defina.org
Telegram: https://t.me/defina_erc
Twitter: https://twitter.com/defina_erc

**/
pragma solidity 0.8.19;
import "./TestLib.sol";
contract reduceFeeFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function reduceFee(uint256 _newFee) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet);
        require(_newFee <= ds._finalBuyTax && _newFee <= ds._finalSellTax);
        ds._finalBuyTax = _newFee;
        ds._finalSellTax = _newFee;
    }
}
