// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract getBrigdeBuyTokenFromBSCAddressFacet is Ownable {
    using SafeMath for uint256;

    function getBrigdeBuyTokenFromBSCAddress() public view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._brigdeBuyTokenFromBSC;
    }
}
