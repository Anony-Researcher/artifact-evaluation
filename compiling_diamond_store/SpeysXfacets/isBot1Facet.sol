// SPDX-License-Identifier: UNLICENSE

/*

SpeysX - $SPEYSX

hop in teh rockot, we gewn to teh mewn and mors with SpeysX 🚀

🌐 websoit: https://SpeysX.co/
❌ x: https://x.com/SpeysXETH
✉️ tg: https://t.me/SpeysXETH

*/

pragma solidity 0.8.23;
import "./TestLib.sol";
contract isBot1Facet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isBot1(address a) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.bots[a];
    }
}
