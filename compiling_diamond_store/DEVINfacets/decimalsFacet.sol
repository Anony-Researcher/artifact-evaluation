// SPDX-License-Identifier: Unlicensed

/*


https://t.me/devinaiportal

https://twitter.com/devinai_erc


World's First AI Software Engineer 'DEVIN'

https://twitter.com/cognition_labs/status/1767548763134964000


https://siliconangle.com/2024/03/12/cognition-launches-devin-generative-ai-powered-coding-engineer/
https://coingape.com/ai-news-cognition-labs-unleashes-devin-worlds-first-ai-software-engineer/



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
