// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract getInSellFacet is Ownable {
    using SafeMath for uint256;

    function getInSell() public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.inSell;
    }
}
