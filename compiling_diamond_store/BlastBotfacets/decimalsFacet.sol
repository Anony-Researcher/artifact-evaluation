// SPDX-License-Identifier: UNLICENSE

/*

Website: https://www.blastbot.pro/
Telegram: https://t.me/blastbotentry
Twitter: https://twitter.com/RealBlastBot


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
