// SPDX-License-Identifier: UNLICENSE

/*

Apple's competitor to CHATGPT

http://applerealm.xyz/

https://t.me/AppleRealm

https://www.timesnownews.com/technology-science/apples-new-ai-system-realm-can-beat-openais-gpt-4-all-we-know-so-far-article-108980006/amp

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
