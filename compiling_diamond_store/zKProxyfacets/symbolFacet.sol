/**
Website: zKProxy.tech
Telegram: @zkproxy
Twitter: https://twitter.com/ZKPr0xy
Gitbook:https://docs.zkproxy.tech/
*/

//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.4;
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
