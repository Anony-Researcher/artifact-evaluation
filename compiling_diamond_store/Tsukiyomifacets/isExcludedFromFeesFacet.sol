/*────────────────────────────┐

  Telegram: https://t.me/TsukiyomiPortal
  Twitter: https://twitter.com/Tsukiyomi_io
  Reddit: https://www.reddit.com/user/Tsukiyomi_io/
  Medium: https://medium.com/@Tsukiyomi_ 

  Developed by coinsult.net                             
 _____     _             _ _   
|     |___|_|___ ___ _ _| | |_ 
|   --| . | |   |_ -| | | |  _|
|_____|___|_|_|_|___|___|_|_|  
                               
  t.me/coinsult_tg
──────────────────────────────┘

 SPDX-License-Identifier: MIT */

pragma solidity 0.8.19;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20 {
    using Address for address payable;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
