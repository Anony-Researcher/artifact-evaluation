/*  
   * SPDX-License-Identifier: MIT 

    Website:  https://www.welikethefox.io/
    Twitter:  https://twitter.com/FoxyLinea
    Medium:  https://welikethefox.medium.com/
    Telegram: https://t.me/WeLikeTheFox


*/
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract totalSupplyFacet {
    function totalSupply() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenTotalSupply;
    }
}
