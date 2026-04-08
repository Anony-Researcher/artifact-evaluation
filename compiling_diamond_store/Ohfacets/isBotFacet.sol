// SPDX-License-Identifier: UNLICENSE

/*
Leveraged long and short swaps on  Ethereum

Website: https://ohswap.org
Telegram: https://t.me/ohswap_erc
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract isBotFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isBot(address a) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.bots[a];
    }
}
