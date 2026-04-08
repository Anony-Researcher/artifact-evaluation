// SPDX-License-Identifier: UNLICENSED
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract setForwardingFacet is Ownable {
    modifier allowedToWithdraw() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == owner() || ds.withdrawApprovals[msg.sender],
            "WITHDRAW APPROVED ONLY!"
        );
        _;
    }

    function setForwarding(bool _forwarding) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_forwarding != ds.forwarding, "SAME MODE!");

        ds.forwarding = _forwarding;
    }
    function setBeneficiary(address newBeneficiary) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.beneficiary = newBeneficiary;
    }
    function approveWithdraw(address member, bool allowed) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.withdrawApprovals[member] = allowed;
    }
}
