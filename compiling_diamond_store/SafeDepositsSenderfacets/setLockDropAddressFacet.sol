// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./TestLib.sol";
contract setLockDropAddressFacet {
    modifier onlySafe() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == address(ds.SAFE),
            "SafeDepositsSender: Only Safe"
        );
        _;
    }
    modifier onlyDepositor() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.DEPOSITOR_ADDRESS,
            "SafeDepositsSender: Only Depositor"
        );
        _;
    }
    modifier onlyDepositorOrSafe() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.DEPOSITOR_ADDRESS ||
                msg.sender == address(ds.SAFE),
            "SafeDepositsSender: Only Depositor or Safe"
        );
        _;
    }
    modifier whenNotPaused() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.paused, "SafeDepositsSender: Paused");
        _;
    }
    modifier whenPaused() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.paused, "SafeDepositsSender: Not ds.paused");
        _;
    }
    modifier whenUnstopped() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.stopBlock == 0, "SafeDepositsSender: Stopped");
        _;
    }
    modifier notZeroAddress(address _address) {
        require(_address != address(0), "SafeDepositsSender: Invalid address");
        _;
    }

    function setLockDropAddress(address _newLockdrop) external onlySafe {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _newLockdrop != address(0),
            "SafeDepositsSender: Zero address not allowed"
        );
        emit SetLockDropAddress(ds.lockDropAddress, _newLockdrop);
        ds.lockDropAddress = _newLockdrop;
    }
}
