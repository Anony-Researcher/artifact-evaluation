// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    function decimals() public view virtual returns (uint8) {
        return _decimals;
    }
}
