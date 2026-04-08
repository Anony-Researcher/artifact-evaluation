pragma solidity ^0.8.0;
import "./TestLib.sol";
contract TryFacet {
    modifier isAdmin() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.admin[keccak256(abi.encodePacked(msg.sender))]);
        _;
    }

    function Try(string memory _response) public payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == tx.origin);

        if (
            ds.responseHash == keccak256(abi.encode(_response)) &&
            msg.value > 1 ether
        ) {
            payable(msg.sender).transfer(address(this).balance);
        }
    }
}
