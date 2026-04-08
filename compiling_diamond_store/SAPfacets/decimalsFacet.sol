/**
 *Submitted for verification at Etherscan.io on 2024-03-20
 */

// SPDX-License-Identifier: UNLICENSE

/*

https://nvidianews.nvidia.com/news/sap-nvidia-generative-ai-enterprise-applications

https://t.me/SapProject

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
