// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract getRefOfFacet is Ownable {
    using SafeMath for uint256;

    function getRefOf(address _address) public view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.refOfs[_address];
    }
}
