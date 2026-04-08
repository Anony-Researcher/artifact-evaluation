// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import "./TestLib.sol";
contract getWnsAddressFacet {
    function getWnsAddress(string memory _label) public view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.wnsAddresses.getWnsAddress(_label);
    }
    function setRecord(uint256 _tokenId, string memory _name) public {
        // require(msg.sender == getWnsAddress("_wnsRegistrar"), "Caller is not Registrar");
        // _tokenIdToName[_tokenId - 1] = _name;
    }
    function upgradeTier(uint256 _tokenId, uint8 _tier) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == getWnsAddress("_wnsRegistrar"),
            "Caller is not Registrar"
        );
        string memory name = getRecord(_tokenId);

        bytes memory nameBytes = abi.encodePacked(name);
        bytes memory tierBytes = abi.encodePacked(_tier);
        bytes memory newRecord = bytes.concat(nameBytes, tierBytes);

        ds._tokenIdToDetails[_tokenId] = newRecord;
    }
    function getRecord(uint256 _tokenId) public view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._tokenIdToDetails[_tokenId].length > 1) {
            bytes memory record = ds._tokenIdToDetails[_tokenId];
            (string memory name, ) = splitRecord(record);

            return name;
        } else {
            return ds.wnsRegistry_v1.getRecord(_tokenId);
        }
    }
    function splitRecord(
        bytes memory record
    ) internal pure returns (string memory name, uint8 tier) {
        require(record.length > 1, "Record is too short.");

        tier = uint8(record[record.length - 1]);

        bytes memory nameBytes = new bytes(record.length - 1);
        for (uint i = 0; i < record.length - 1; i++) {
            nameBytes[i] = record[i];
        }

        name = string(nameBytes);

        return (name, tier);
    }
    function getTier(uint256 _tokenId) public view returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds._tokenIdToDetails[_tokenId].length > 1) {
            bytes memory record = ds._tokenIdToDetails[_tokenId];
            (, uint8 tier) = splitRecord(record);

            return tier;
        } else {
            return 0;
        }
    }
}
