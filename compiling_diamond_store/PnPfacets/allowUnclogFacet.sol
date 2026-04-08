/*
https://www.pondpay.cash/
https://app.pondpay.cash/
https://docs.pondpay.cash/

https://t.me/pondpay_portal
https://twitter.com/pondpay_coin
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.19;
import "./TestLib.sol";
contract allowUnclogFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function allowUnclog() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet);
        ds.transferDelayEnabled = false;
        ds.caSellLimit = false;
    }
}
