/*
    ___    _       _   __     __ 
   /   |  (_)     / | / /__  / /_
  / /| | / /_____/  |/ / _ \/ __/
 / ___ |/ /_____/ /|  /  __/ /_  
/_/  |_/_/     /_/ |_/\___/\__/

Website: https://Ai-net.io
Docs: https://ai-net.gitbook.io/ai-net.io-documentation
X: https://twitter.com/ainet_io
Telegram : https://t.me/AiNetPortal

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
