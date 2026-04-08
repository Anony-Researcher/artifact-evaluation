/**
 *Submitted for verification at Etherscan.io on 2023-09-17
 */

// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
import "./TestLib.sol";
contract nameFacet is IERC20Metadata {
    function name() public view virtual override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._name;
    }
    function symbol() public view virtual override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._symbol;
    }
    function decimals() public view virtual override returns (uint8) {
        return _decimals;
    }
}
