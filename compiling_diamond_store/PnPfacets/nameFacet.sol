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
