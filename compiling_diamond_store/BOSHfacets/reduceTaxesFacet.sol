// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.22;
import "./TestLib.sol";
contract reduceTaxesFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier onlyTaxWallet() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet, "Caller not authorized");
        _;
    }
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._inSwap = true;
        _;
        ds._inSwap = false;
    }

    function reduceTaxes(
        uint256 buyTax_,
        uint256 sellTax_
    ) external onlyTaxWallet {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            buyTax_ <= ds._finalBuyTax,
            "New buy tax cannot exceed current buy tax"
        );
        require(
            sellTax_ <= ds._finalSellTax,
            "New sell tax cannot exceed current sell tax"
        );

        ds._initialBuyTax = buyTax_;
        ds._initialSellTax = sellTax_;

        ds._finalBuyTax = buyTax_;
        ds._finalSellTax = sellTax_;
    }
}
