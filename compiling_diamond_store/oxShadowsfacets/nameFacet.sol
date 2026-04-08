// SPDX-License-Identifier: MIT
/**

Telegram: https://t.me/xShadowsETH
Website: https://0x-shadows-ethglobal-circuit-breaker-2024.vercel.app/

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
