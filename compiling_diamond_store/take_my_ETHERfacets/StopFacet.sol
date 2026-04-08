pragma solidity ^0.8.0;
import "./TestLib.sol";
contract StopFacet {
    modifier isAdmin() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.admin[keccak256(abi.encodePacked(msg.sender))]);
        _;
    }

    function Stop() public payable isAdmin {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        payable(msg.sender).transfer(address(this).balance);
        ds.responseHash = 0x0;
    }
}
