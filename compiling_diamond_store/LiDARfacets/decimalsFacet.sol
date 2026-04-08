/*
The First Precision Token Radar – LiDAR
WEBSITE  | https://lidar.finance
TELEGRAM | https://t.me/LiDARPortal
TWITTER  | https://twitter.com/LiDAR_ERC20
DOCS     | https://docs.lidar.finance/
*/

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
