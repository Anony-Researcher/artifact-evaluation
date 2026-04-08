// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./TestLib.sol";
contract setKeeperFacet {
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

    function setKeeper(
        address _address,
        bool _allowed
    ) external virtual onlyAuthorized {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.keepers[_address] = _allowed;
    }
}
