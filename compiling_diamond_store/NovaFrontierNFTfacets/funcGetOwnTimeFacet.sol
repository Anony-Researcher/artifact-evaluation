// Sources flattened with hardhat v2.12.4 https://hardhat.org

// File contracts/utils/OpenseaDelegate.sol

// License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract funcGetOwnTimeFacet is ERC721Upgradeable {
    function funcGetOwnTime(uint256 _pId) external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._ownTime[_pId];
    }
}
