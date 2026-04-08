// SPDX-License-Identifier: MIT
/*
   ▄████▄  ██▀███  ▄▄▄       ██▓ ▄████     █     █░ ██▀███   ▒█████   ███▄    █   ▄████ 
  ▒██▀ ▀█ ▓██ ▒ ██▒████▄    ▓██▒██▒ ▀█▒   ▓█░ █ ░█░▓██ ▒ ██▒▒██▒  ██▒ ██ ▀█   █  ██▒ ▀█▒
  ▒▓█    ▄▓██ ░▄█ ▒██  ▀█▄  ▒██▒██░▄▄▄░   ▒█░ █ ░█ ▓██ ░▄█ ▒▒██░  ██▒▓██  ▀█ ██▒▒██░▄▄▄░
  ▒▓▓▄ ▄██▒██▀▀█▄ ░██▄▄▄▄██ ░██░▓█  ██▓   ░█░ █ ░█ ▒██▀▀█▄  ▒██   ██░▓██▒  ▐▌██▒░▓█  ██▓
  ▒ ▓███▀ ░██▓ ▒██▒▓█   ▓██▒░██░▒▓███▀▒   ░░██▒██▓ ░██▓ ▒██▒░ ████▓▒░▒██░   ▓██░░▒▓███▀▒
  ░ ░▒ ▒  ░ ▒▓ ░▒▓░▒▒   ▓▒█░░▓  ░▒   ▒    ░ ▓░▒ ▒  ░ ▒▓ ░▒▓░░ ▒░▒░▒░ ░ ▒░   ▒ ▒  ░▒   ▒ 
    ░  ▒    ░▒ ░ ▒░ ▒   ▒▒ ░ ▒ ░ ░   ░      ▒ ░ ░    ░▒ ░ ▒░  ░ ▒ ▒░ ░ ░░   ░ ▒░  ░   ░ 
  ░         ░░   ░  ░   ▒    ▒ ░ ░   ░      ░   ░    ░░   ░ ░ ░ ░ ▒     ░   ░ ░ ░ ░   ░ 
  ░ ░        ░          ░  ░ ░       ░        ░       ░         ░ ░           ░       ░ 
  ░                                                                                     
*/
// Website:  https://craigwrong.lol
// Telegram: https://t.me/craigwrong
// X :  https://twitter.com/craig_wron13561

pragma solidity ^0.8.13;
import "./TestLib.sol";
contract isExcludedFromFeesFacet is ERC20 {
    using SafeMath for uint256;

    function isExcludedFromFees(address account) external view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._isExcludedFromFees[account];
    }
}
