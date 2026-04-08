// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;
import "./TestLib.sol";
contract indexFacet is Ownable {
    using SafeMath for uint256;
    using LowGasSafeMath for uint32;
    using SafeERC20 for IERC20;
    using SafeERC20 for IxVexaris;

    function index() external view returns (uint) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.xVexaris.index();
    }
}
