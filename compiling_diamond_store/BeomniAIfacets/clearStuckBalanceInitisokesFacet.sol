/**
      Telegram : https://t.me/BeomniAI_ETH

      Website: https://www.beomniai.com/

      Twitter: https://twitter.com/BeomniAI_

      Medium: https://medium.com/@ajith.yalvil/2022-new-human-robot-7d79e8a8acef

/**
*/
// SPDX-License-Identifier: MIT
/*

    

*/

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract clearStuckBalanceInitisokesFacet is ERC20 {
    using Address for address payable;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!ds._interlock) {
            ds._interlock = true;
            _;
            ds._interlock = false;
        }
    }

    function clearStuckBalanceInitisokes() external payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.bontudu = 3;
    }
}
