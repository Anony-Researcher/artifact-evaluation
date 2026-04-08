/*

Anthropic AI next gen AI model $CLAUDE - Claude 3

https://twitter.com/elonmusk/status/1764703268419108917
https://t.me/Claude3Token


*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
