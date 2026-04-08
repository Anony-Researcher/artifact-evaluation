// SPDX-License-Identifier: UNLICENSE

/*
Pepe Times is a simple, honest blockchain entirely built to be community-driven and to give more power to the modern believers in the power of meme- the pepe. No venture capitalists, no extravagant pledges beyond our reach, like achieving 1 Trillion Users with a groundbreaking consensus algorithm.

Website: https://pepetime.vip
Telegram: https://t.me/PepeTimes_ERC
Twitter: https://twitter.com/PepeTimes_ERC
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
