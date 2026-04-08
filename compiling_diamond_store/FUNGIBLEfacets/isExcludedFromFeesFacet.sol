/*
______ _   _ _   _ _____ ___________ _      _____ 
|  ___| | | | \ | |  __ \_   _| ___ \ |    |  ___|
| |_  | | | |  \| | |  \/ | | | |_/ / |    | |__  
|  _| | | | | . ` | | __  | | | ___ \ |    |  __| 
| |   | |_| | |\  | |_\ \_| |_| |_/ / |____| |___ 
\_|    \___/\_| \_/\____/\___/\____/\_____/\____/ 
                                                  

https://fungible.live
https://twitter.com/fungiblelive
https://t.me/fungiblelive

*/

// SPDX-License-Identifier: Unlicensed
pragma solidity 0.8.9;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20, Ownable {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
