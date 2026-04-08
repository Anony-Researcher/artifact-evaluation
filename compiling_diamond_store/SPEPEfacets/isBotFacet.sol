// SPDX-License-Identifier: UNLICENSE

/*
    MISSED PEPE? DON'T MISS SUPER PEPE!
    https://superpepecoin.vip/
    https://twitter.com/super_pepecoin
    https://t.me/superpepecoineth
    https://www.tiktok.com/@victorreznov101/video/7163066179639201070
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
