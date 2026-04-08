// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;
import "./TestLib.sol";
contract getContractsCountFacet {
    function getContractsCount() external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.nftInfo.length;
    }
}
