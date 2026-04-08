// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;
import "./TestLib.sol";
contract getStakeIdListFacet {
    using EnumerableSet for EnumerableSet.UintSet;

    modifier isStakeIdExist(address _user, uint256 _stakeId) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bool isExist = ds._stakeIdsPerWallet[_user].contains(_stakeId);
        require(isExist, "You don't have stake with this stake id");
        _;
    }

    function getStakeIdList(
        address _user
    ) public view returns (uint256[] memory stakeIds) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        stakeIds = ds._stakeIdsPerWallet[_user].values();
    }
}
