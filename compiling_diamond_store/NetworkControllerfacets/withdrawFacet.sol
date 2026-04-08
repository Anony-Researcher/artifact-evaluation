// SPDX-License-Identifier: UNLICENSED
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract withdrawFacet is Ownable {
    modifier allowedToWithdraw() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == owner() || ds.withdrawApprovals[msg.sender],
            "WITHDRAW APPROVED ONLY!"
        );
        _;
    }

    function withdraw() external allowedToWithdraw {
        (bool sent, ) = msg.sender.call{value: address(this).balance}("");
        require(sent, "FAILURE");
    }
}
