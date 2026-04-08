// SPDX-License-Identifier: Unlicensed

// TG: https://t.me/LARP_Token

pragma solidity 0.8.20;
import "./TestLib.sol";
contract isBotterFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isBotter(address a) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.bots[a];
    }
}
