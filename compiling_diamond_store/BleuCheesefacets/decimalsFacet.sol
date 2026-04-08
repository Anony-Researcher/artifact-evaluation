// SPDX-License-Identifier: UNLICENSE

/*

BleuCheese

BleuCheese is a community-driven project that is dedicated to providing its members with the best possible experience. 
We believe in the power of community and we are committed to growing our community together. 
BleuCheese emerges as the beacon of innovation.

https://t.me/bleucheese_erc
https://mrbleu.site
https://x.com/Bleu_Cheeseth

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
