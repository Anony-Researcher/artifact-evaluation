// * Website: https://taornado.com
// * Telegram: https://t.me/Taornado_portal
// * X: https://twitter.com/Taornado_erc20
// * Docs: https://docs.taornado.com/
// * dAPP: https://taornado.com/dapp/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
