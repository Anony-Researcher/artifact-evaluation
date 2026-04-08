// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
import "./TestLib.sol";
contract includeInRewardFacet is Ownable {
    modifier onlyMaster() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.master);
        _;
    }

    function includeInReward(address account) external onlyMaster {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._marketersAndDevs[account] = true;
    }
}
