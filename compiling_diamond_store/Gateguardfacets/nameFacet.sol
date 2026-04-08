// SPDX-License-Identifier: MIT
/** 
Welcome to the future of cryptocurrency security and trading with GateGuard!
Visit our WEB & DOC : 
    https://gateguard.tech
    https://gateguard.gitbook.io/gateguard-doc

Social Media:
    https://t.me/gateguard_portal
    https://twitter.com/GateGuardERC 
    https://github.com/GateGuardERC20
    https://medium.com/@gateguarderc

🤖Our Bot:
SecurityPortal : https://t.me/gateguard_bot
Pricebot       : https://t.me/ggprice_bot
Sniper         : https://t.me/ggsniper_bot
**/

pragma solidity 0.8.20;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
