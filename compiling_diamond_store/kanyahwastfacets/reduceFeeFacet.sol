// SPDX-License-Identifier: UNLICENSE

/*

Kanyah Wast $YAH

yo yo yo its me kanyah wast da one an onlee aint no test im da rappin king ma rhymes ar a blast makin all dem toons dat forevr last i got fame i got game all dem othr rappas dey jus lame i rime 

i am dropping vultures 2 toeday, i make many rich

https://www.billboard.com/music/chart-beat/kanye-west-ty-dolla-sign-carnival-number-1-tiktok-billboard-top-50-1235624809/amp/

website: https://kanyahwast.xyz
x: https://x.com/KanyahWast
telegram: https://t.me/KanyahWast



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
