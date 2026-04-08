// SPDX-License-Identifier: UNLICENSE

/*
Leveraged long and short swaps on  Ethereum

Website: https://ohswap.org
Telegram: https://t.me/ohswap_erc
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
