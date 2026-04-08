// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract claimFacet is ERC20 {
    using SafeMath for uint256;

    function claim() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address beneficiary = msg.sender;
        TestLib.VestingData storage data = ds.vestingData[beneficiary];
        require(data.balance > 0, "No tokens to claim");

        uint256 unreleased = releasableAmount(beneficiary);
        require(unreleased > 0, "No tokens are due for release");

        data.released = data.released.add(unreleased);
        _transfer(address(this), beneficiary, unreleased);
    }
    function releasableAmount(
        address beneficiary
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.VestingData storage data = ds.vestingData[beneficiary];
        return vestedAmount(beneficiary).sub(data.released);
    }
    function vestedAmount(address beneficiary) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.VestingData storage data = ds.vestingData[beneficiary];
        uint256 currentTime = block.timestamp;
        uint256 startTime = data.startTime;
        uint256 cliffDuration = data.cliffDuration;
        uint256 duration = data.duration;
        uint256 slicePeriod = data.slicePeriod;
        uint256 totalAmount = data.balance;

        if (currentTime < startTime.add(cliffDuration)) {
            return 0;
        } else if (currentTime >= startTime.add(duration)) {
            return totalAmount;
        } else {
            uint256 elapsedPeriods = (
                currentTime.sub(startTime.sub(cliffDuration))
            ).div(slicePeriod);
            uint256 totalPeriods = duration.div(slicePeriod);
            return totalAmount.mul(elapsedPeriods).div(totalPeriods);
        }
    }
}
