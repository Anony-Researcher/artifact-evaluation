// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract setBrigdeBuyTokenFromBSCAddressFacet is Ownable {
    using SafeMath for uint256;

    function setBrigdeBuyTokenFromBSCAddress(
        address brigdeBuyTokenFromBSC
    ) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._brigdeBuyTokenFromBSC = brigdeBuyTokenFromBSC;
    }
}
