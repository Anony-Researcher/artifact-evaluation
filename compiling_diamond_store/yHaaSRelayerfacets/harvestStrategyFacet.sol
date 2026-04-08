// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;
import "./TestLib.sol";
contract harvestStrategyFacet {
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

    function harvestStrategy(
        address _strategyAddress
    ) public onlyKeepers returns (uint256 profit, uint256 loss) {
        (profit, loss) = StrategyAPI(_strategyAddress).report();
    }
}
