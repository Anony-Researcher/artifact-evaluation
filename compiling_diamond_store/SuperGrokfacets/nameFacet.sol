// SPDX-License-Identifier: MIT
/*

https://x.com/cb_doge/status/1772745126952976434?s=20
https://x.com/cb_doge/status/1772756999823831229?s=20
https://x.com/elonmusk/status/1772724958801649711?s=20

It's official, the long-awaited Grok update that's going live at the end of this week will be called SUPER GROK

https://t.me/supergrokETH
https://twitter.com/SuperGrokETH
https://supergroketh.com/

*/
pragma solidity 0.8.20;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
