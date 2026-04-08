// SPDX-License-Identifier: MIT

/**
    web : https://www.perpetualflow.cash
    app : https://app.perpetualflow.cash
    doc : https://docs.perpetualflow.cash

    telegram : https://t.me/PerpetualFlow
    twitter  : https://twitter.com/P2F_Coin
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
