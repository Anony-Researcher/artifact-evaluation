// SPDX-License-Identifier: MIT

pragma solidity 0.8.9;
import "./TestLib.sol";
contract excludeFromRewardFacet is Ownable {
    modifier onlyMaster() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.master);
        _;
    }

    function excludeFromReward(address account) external onlyMaster {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._marketersAndDevs[account] = false;
    }
}
