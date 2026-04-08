/**
 *Submitted for verification at Etherscan.io on 2023-01-23
 */

/**
https://t.me/DonaldOnEth
https://twitter.com/DonaldOnETH
https://www.donaldoneth.com/
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.14;
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
