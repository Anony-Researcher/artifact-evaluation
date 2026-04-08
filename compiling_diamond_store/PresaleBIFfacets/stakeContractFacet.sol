// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "./TestLib.sol";
contract stakeContractFacet is Ownable {
    using SafeMath for uint256;

    function stakeContract() public view returns (IStake) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.stake;
    }
}
