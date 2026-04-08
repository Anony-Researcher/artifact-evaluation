// SPDX-License-Identifier: UNLICENSE

/*
AI Web3 Community Token Brainpup of GPT4.

Website: https://www.animai.tech
Telegram: https://t.me/animai_erc 
Twitter: https://twitter.com/AnimAI_eth
*/

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
