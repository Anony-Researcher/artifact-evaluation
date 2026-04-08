// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract getUSDTTokenFacet is Ownable {
    using SafeMath for uint256;

    function getUSDTToken() public view returns (USDTInterface) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.usdtToken;
    }
}
