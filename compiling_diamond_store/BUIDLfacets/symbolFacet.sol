/*

Website: http://blackrockbuidl.tech
Twitter: https://twitter.com/BUIDLblackrock
Telegram: https://t.me/BUIDLERC20

https://news.bitcoin.com/blackrock-aims-to-launch-tokenized-investment-fund-seeks-sec-nod-for-buidl-fund-on-ethereum/

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
