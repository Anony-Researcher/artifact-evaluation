// SPDX-License-Identifier: UNLICENSE

/*
    $Bubu appears twice in https://www.pepe.vip/
    Pepe hopes $Bubu can become the next Pepe
    https://twitter.com/pepecoineth/status/1679501470964625408
    https://t.me/BuBuCoinErc
*/

pragma solidity 0.8.23;
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
