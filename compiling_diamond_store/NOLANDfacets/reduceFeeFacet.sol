// SPDX-License-Identifier: UNLICENSE

/*

Meet NOLAND, the first human with a Neuralink brain chip capable of playing video games and now able to use "Telepathy" powered by Neuralink to create social media posts. 

tg : https://t.me/NolandArbaugh_erc20

twitter : https://twitter.com/NolandArbaugh_

website : http://nolandarbaugh.site/

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
