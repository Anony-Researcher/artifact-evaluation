// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract rewardBalanceFacet {
    using EnumerableSet for EnumerableSet.UintSet;

    modifier isStakeIdExist(address _user, uint256 _stakeId) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool isExist = ds._stakeIdsPerWallet[_user].contains(_stakeId);
        require(isExist, "You don't have stake with this stake id");
        _;
    }

    function rewardBalance() public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.rewardToken.balanceOf(address(this));
    }
}
