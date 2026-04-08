// SPDX-License-Identifier: UNLICENSE

/*
$PRINT is the next ETH moonshot

Website: https://www.printstake.com
Telegram: https://t.me/printstake
Twitter: https://twitter.com/printstake_eth
Staking Dapp: https://app.printstake.com
*/

pragma solidity 0.8.19;
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
