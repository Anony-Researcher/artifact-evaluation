/**

0xfrax GPU - $0xF


Website:         https://www.0xfraxgpu.com
Utility:         https://app.0xfraxgpu.com
Document:        https://docs.0xfraxgpu.com
Telegram:        https://t.me/frax0xgpu
Twitter:         https://twitter.com/0xfraxgpu


**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
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
