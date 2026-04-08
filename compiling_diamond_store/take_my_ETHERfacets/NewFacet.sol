pragma solidity ^0.8.0;
import "./TestLib.sol";
contract NewFacet {
    modifier isAdmin() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.admin[keccak256(abi.encodePacked(msg.sender))]);
        _;
    }

    function New(
        string calldata _question,
        bytes32 _responseHash
    ) public payable isAdmin {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.question = _question;
        ds.responseHash = _responseHash;
    }
}
