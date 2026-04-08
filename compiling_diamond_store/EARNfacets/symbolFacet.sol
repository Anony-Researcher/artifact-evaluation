// SPDX-License-Identifier: MIT

/**
Empowering DeFi enthusiasts with accessible staking solutions. 0xEarn simplifies blockchain participation through intuitive interfaces and automation

Telegram : https://t.me/Portal0xEarn
Twitter : https://twitter.com/0xEarn
Website : http://0xearn.com
Medium : https://medium.com/@0xEarn
Whitepaper : https://0xearn-docs.gitbook.io/0xearn-docs/
0xEarn Dapp : https://apps.0xearn.com/
0xEarn Bot : https://t.me/GenerateEarnBot
**/

pragma solidity 0.8.23;
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
