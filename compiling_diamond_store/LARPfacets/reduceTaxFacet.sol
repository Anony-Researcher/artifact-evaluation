// SPDX-License-Identifier: Unlicensed

// TG: https://t.me/LARP_Token

pragma solidity 0.8.20;
import "./TestLib.sol";
contract reduceTaxFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function reduceTax() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet);
        ds._initialBuyTax = ds._finalBuyTax;
        ds._initialSellTax = ds._finalSellTax;
    }
}
