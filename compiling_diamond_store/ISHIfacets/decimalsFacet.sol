// SPDX-License-Identifier: UNLICENSE

/*

ISHI $ISHI

ANCESTOR OR GRANDFATHER OF ALL SHIBA INU IN THE WORLD.

INCLUDING FLOKI, DOGE, KABOSU, SHIBA INU.

https://www.asahi.com/ajw/articles/13067772?fbclid=IwAR2zwtD6R3wmPvT_flcNjFUfG-QXBTOxHGayLqrA7UL41X_tkJrS0Uizu0c

https://nobu-tokyo.com/do-you-know-the-ancestor-of-the-shiba-inu-not-shiba-inu-coin/?fbclid=IwAR03FNZvCiOsjgWa6PHY1SU5Xgir5_q3Bx5uHiGVuSSGdO1l1cobWJOnVWE

https://t.me/ishicoinerc

https://twitter.com/ishicoinerc

https://ishitoken.io/

*/

pragma solidity 0.8.23;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
