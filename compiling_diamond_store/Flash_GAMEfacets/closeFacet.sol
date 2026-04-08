pragma solidity ^0.4.26;
import "./TestLib.sol";
contract closeFacet {
    function close() external payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner);
        ds.owner.transfer(address(this).balance);
    }
}
