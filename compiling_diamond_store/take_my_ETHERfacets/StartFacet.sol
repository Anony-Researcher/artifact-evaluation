pragma solidity ^0.8.0;
import "./TestLib.sol";
contract StartFacet {
    modifier isAdmin() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.admin[keccak256(abi.encodePacked(msg.sender))]);
        _;
    }

    function Start(
        string calldata _question,
        string calldata _response
    ) public payable isAdmin {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.responseHash == 0x0) {
            ds.responseHash = keccak256(abi.encode(_response));
            ds.question = _question;
        }
    }
}
