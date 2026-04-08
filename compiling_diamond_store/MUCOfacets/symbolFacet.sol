// SPDX-License-Identifier: Unlicensed

/*
Unlocking liquidity for BRC20s on EVM networks. :left_right_arrow: Dual sided bridge.
MultiConnect Protocol is an innovative endeavor aiming to unify the liquidity amongst Bitcoin network (BTC) and EVM networks. 

Web: https://multiconnect.pro
App: https://app.multiconnect.pro
X: https://x.com/MultiConnect_X
Tg: https://t.me/multiconnect_pro_official
M: https://medium.com/@multiconnect.pro
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isEtneringSecured = true;
        _;
        ds._isEtneringSecured = false;
    }

    function symbol() public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.symbol_;
    }
}
