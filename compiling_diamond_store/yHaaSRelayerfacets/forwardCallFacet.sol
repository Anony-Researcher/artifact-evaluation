// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./TestLib.sol";
contract forwardCallFacet {
    modifier onlyKeepers() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.owner ||
                ds.keepers[msg.sender] == true ||
                msg.sender == ds.governance,
            "!keeper yHaaSProxy"
        );
        _;
    }
    modifier onlyAuthorized() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.owner || msg.sender == ds.governance,
            "!authorized"
        );
        _;
    }
    modifier onlyGovernance() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.governance, "!ds.governance");
        _;
    }

    function forwardCall(
        address debtAllocatorAddress,
        bytes memory data
    ) public onlyKeepers returns (bool success) {
        (success, ) = debtAllocatorAddress.call(data);
    }
}
