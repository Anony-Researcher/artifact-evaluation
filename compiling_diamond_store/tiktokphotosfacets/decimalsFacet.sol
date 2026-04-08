/**


https://t.me/TiktokPhotos
https://x.com/cb_doge/status/1767284165177942196?s=20


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
