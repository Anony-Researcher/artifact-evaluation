// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;

interface WnsRegistryInterface {
    function getRecord(bytes32 _hash) external view returns (uint256);
    function getRecord(uint256 _tokenId) external view returns (string memory);
}

interface WnsAddressesInterface {
    function owner() external view returns (address);
    function getWnsAddress(
        string memory _label
    ) external view returns (address);
}

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        address WnsRegistry_v1;
        address WnsAddresses;
        WnsRegistryInterface wnsRegistry_v1;
        WnsAddressesInterface wnsAddresses;
        mapping(bytes32 => uint256) _hashToTokenId;
        mapping(uint256 => bytes) _tokenIdToDetails;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
