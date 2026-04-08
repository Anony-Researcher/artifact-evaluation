/**

// SPDX-License-Identifier: UNLICENSE

/*

    Telegram: https://t.me/Kirby_Inu_ETH

    Twitter: https://twitter.com/Kirby_Inu_ETH

    Website: https://www.kirby-inu.com/


*/
pragma solidity 0.8.25;
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
