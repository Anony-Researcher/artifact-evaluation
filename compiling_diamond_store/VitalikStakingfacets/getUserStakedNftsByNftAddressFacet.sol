//SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import "./TestLib.sol";
contract getUserStakedNftsByNftAddressFacet is DividendTracker, Ownable {
    using EnumerableSet for EnumerableSet.UintSet;
    using EnumerableSet for EnumerableSet.AddressSet;

    function getUserStakedNftsByNftAddress(
        address _nftAddress,
        address _user
    ) external view returns (uint256[] memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.holderNftsStaked[_nftAddress][_user].values();
    }
}
