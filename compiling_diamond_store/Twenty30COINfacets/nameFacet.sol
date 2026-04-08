// SPDX-License-Identifier: MIT

/** 

Website:  https://2030coin.site
Twitter:  https://twitter.com/2030COIN_ETH
Telegram: https://t.me/InfinityToken2030COIN
GitBook:  https://2030coin.gitbook.io/

**/

pragma solidity 0.8.21;
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
