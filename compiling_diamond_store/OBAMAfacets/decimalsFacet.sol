// SPDX-License-Identifier: UNLICENSE

/*

Yes We Can - $OBAMA
A token to look back on the good times.
Barack Obama is regarded by many as the finest president of an era when the United States stood as a true global powerhouse.

yeswecaneth.com
t.me/yeswecaneth
x.com/yeswecan_eth

*/

// Sources flattened with hardhat v2.7.0 https://hardhat.org

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
