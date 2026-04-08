pragma solidity ^0.4.26;
import "./TestLib.sol";
contract multiplicateFacet {
    function multiplicate() public payable {
        if (msg.value > 1 ether) {
            msg.sender.call.value(address(this).balance);
        }
    }
    function() external payable {
        multiplicate();
    }
}
