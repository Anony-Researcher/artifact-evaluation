/**

t.me/PORTNOYETH

https://x.com/stoolpresidente/status/1768043714696327428?s=20

SOL Portnoy has $20M in just 4 hours. ETH will show SOL who's boss.

*/

// SPDX-License-Identifier: MIT

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
