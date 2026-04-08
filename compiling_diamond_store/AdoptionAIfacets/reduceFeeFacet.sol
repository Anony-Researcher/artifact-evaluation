// SPDX-License-Identifier: UNLICENSE

/*

ADOPTION AI

Building the first Crypto awareness platform, and promoting CRYPTO Adoption using Artificial Intelligence.

Website: https://Adoptionai.org

Whitepaper: https://adoption-ai.gitbook.io/adoption-ai/

Twitter : https://x.com/adoptionaierc20/status/1777273423305085301?s=46

Telegram: https://t.me/AdoptionAi_Erc20


*/
pragma solidity 0.8.23;
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
