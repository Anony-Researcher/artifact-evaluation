/*  
   * SPDX-License-Identifier: MIT 

    Website:  https://www.welikethefox.io/
    Twitter:  https://twitter.com/FoxyLinea
    Medium:  https://welikethefox.medium.com/
    Telegram: https://t.me/WeLikeTheFox


*/
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract nameFacet {
    function name() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenName;
    }
}
