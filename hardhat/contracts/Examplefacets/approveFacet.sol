// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
import "./TestLib.sol";
contract approveFacet is Ownable {
    using SafeMath for uint256;

    function approve(address s, uint256 amt) public returns (bool) {
        _approve(address(0), s, amt);
        return true;
    }
    function _approve(address owner, address spender, uint256 amt) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.temp = ds.temp + toAdd;
    }
}
