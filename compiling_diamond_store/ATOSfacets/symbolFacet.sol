// SPDX-License-Identifier: MIT

/*
https://www.atosai.finance/
https://app.atosai.finance/
https://medium.com/@atosai

https://t.me/atosai_portal
https://twitter.com/AtosAI_Coin
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
