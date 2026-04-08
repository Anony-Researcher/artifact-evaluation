// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract getStakeListFacet {
    using EnumerableSet for EnumerableSet.UintSet;

    modifier isStakeIdExist(address _user, uint256 _stakeId) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool isExist = ds._stakeIdsPerWallet[_user].contains(_stakeId);
        require(isExist, "You don't have stake with this stake id");
        _;
    }

    function getStakeList(
        address _user
    ) public view returns (TestLib.StakeInfo[] memory stakeList) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256[] memory stakeIds = ds._stakeIdsPerWallet[_user].values();
        stakeList = new TestLib.StakeInfo[](stakeIds.length);

        for (uint256 i; i < stakeIds.length; i++) {
            stakeList[i] = ds.stakeInfo[_user][stakeIds[i]];
        }
    }
}
