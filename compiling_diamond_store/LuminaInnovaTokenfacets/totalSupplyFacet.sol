// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view virtual override returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
}
