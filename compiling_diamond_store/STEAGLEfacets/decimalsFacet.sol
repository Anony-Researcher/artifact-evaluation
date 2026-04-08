// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract decimalsFacet is ERC20 {
    function decimals() public view virtual override returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._decimals;
    }
    function mint(address receiver, uint256 amount) public onlyOwner {
        _mint(receiver, amount);
    }
}
