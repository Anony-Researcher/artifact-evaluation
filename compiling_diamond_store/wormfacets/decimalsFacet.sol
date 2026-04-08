/**

https://t.me/Wormgodemperor
https://x.com/x/status/1764382247132496128?s=46&t=Fy14sqDz2upGEF0vQnjj0w


// SPDX-License-Identifier: UNLICENSE



*/
pragma solidity 0.8.23;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
