/**
    Eth will never be the same
    
    Website:  https://proofofsasquatch.com
    Twitter:  https://twitter.com/proofofsas
    Telegram: https://t.me/proofofsasquatch

    ⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⣀⣀⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣿⣿⡟⠻⣿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣤⣤⣿⣿⡿⠁⠀⡿⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠠⣽⣿⣿⣿⣿⣿⣿⣿⣶⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⢠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⢠⣰⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣶⣧⣀⡀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣾⣿⣿⠟⠁⣾⣿⣿⣿⣿⣿⣿⠈⠙⠿⡿⢿⣿⣿⣷⣤⡀⠀⠀
⠀⠀⠠⣤⣴⣾⡿⠋⠁⠀⢸⣿⣿⣿⣿⣿⣿⣿⣄⠀⠀⠀⠀⠈⠉⠀⠈⠃⠀⠀
⠀⠀⠀⠈⠉⠉⠀⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣦⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠻⣿⣿⣿⣿⡟⢿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣹⣿⣿⡿⠀⠀⠙⢿⣿⣿⣆⠀⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⢤⣶⣾⣿⣿⣿⣿⠃⠀⠀⠀⠈⣿⣿⣟⠃⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⣰⣿⣿⠟⠉⠀⠋⠁⠀⠀⠀⠀⠀⣿⣿⡿⠃⠀⠀⠀⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠙⠛⠻⠿⣷⡆⠀⠀⠀⠀⠀⠀⢀⣿⣿⣷⣶⣶⣶⣦⠀⠀⠀⠀
⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠈⠉⠉⠉⠉⠀⠀⠀⠀
**/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20, Ownable {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
