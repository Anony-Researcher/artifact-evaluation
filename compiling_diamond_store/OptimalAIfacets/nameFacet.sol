// SPDX-License-Identifier: MIT

/*
    Web     : https://optimalai.dev
    App     : https://app.optimalai.dev
    Doc     : https://docs.optimalai.dev

    Twitter : https://twitter.com/optimalaipro
    Telegram: https://t.me/optimalaiprotocol
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwapAndLiquify = true;
        _;
        ds.inSwapAndLiquify = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
