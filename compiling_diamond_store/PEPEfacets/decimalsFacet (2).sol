// SPDX-License-Identifier: UNLICENSE

/*

Website: http://pepeinuerc.wtf/
Twitter: https://twitter.com/PepeInu_onEth
Telegram: https://t.me/PepeInuu

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
