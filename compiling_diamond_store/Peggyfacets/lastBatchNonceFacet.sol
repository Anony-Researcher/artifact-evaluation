// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract lastBatchNonceFacet {
    using SafeERC20 for IERC20;

    function lastBatchNonce(
        address _erc20Address
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.state_lastBatchNonces[_erc20Address];
    }
}
