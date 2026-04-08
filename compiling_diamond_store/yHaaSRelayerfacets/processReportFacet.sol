// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./TestLib.sol";
contract processReportFacet {
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

    function processReport(
        address _vaultAddress,
        address _strategyAddress
    ) public onlyKeepers returns (uint256 gain, uint256 loss) {
        (gain, loss) = VaultAPI(_vaultAddress).process_report(_strategyAddress);
    }
}
