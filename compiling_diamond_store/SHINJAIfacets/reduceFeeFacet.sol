// SPDX-License-Identifier: UNLICENSE

/*
    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
    SHINJAI 
    ▭▭ι═══════ ﺤ · ❟❛❟ · 𒅒𒈔𒅒𒇫𒄆.

    Lightning-Fast Creation of crypto project campaigns, enhanced by AI.

    Presenting Shinjai, your premier solution for the strategic creation and proficient management of crypto project campaigns. With the integration of cutting-edge AI technology, Shinjai facilitates swift and efficient development of engaging initiatives, including whitelists, giveaways, and raffles. Our meticulously crafted platform caters specifically to the discerning needs of crypto aficionados, offering sophisticated tools for seamless community interaction and meticulous campaign oversight. Elevate your project's presence and engagement with Shinjai – where professionalism meets AI-powered excellence.

    ❟❛❟ Whitepaper: https://shinjai.gitbook.io/shinjai/raid-zone
    ❟❛❟ DApp: https://dapp.shinjai.io/
    ❟❛❟ Website - https://www.shinjai.com
    ❟❛❟ Twitter -  https://twitter.com/ShinjaiToken
    ❟❛❟ Telegram  - https://t.me/shinjaitoken

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
