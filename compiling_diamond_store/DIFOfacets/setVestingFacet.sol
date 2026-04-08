// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract setVestingFacet is ERC20 {
    using SafeMath for uint256;

    function setVesting(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriod,
        uint256 _amount
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_beneficiary != address(0), "Invalid beneficiary address");
        require(_amount > 0, "Invalid amount");

        TestLib.VestingData storage data = ds.vestingData[_beneficiary];
        data.balance = _amount;
        data.startTime = _start;
        data.cliffDuration = _cliff;
        data.duration = _duration;
        data.slicePeriod = _slicePeriod;
        data.released = 0;

        if (data.balance > 0 && data.released == 0) {
            ds.vestingBeneficiaries.push(_beneficiary);
        }

        emit VestingScheduled(
            _beneficiary,
            _start,
            _cliff,
            _duration,
            _slicePeriod,
            _amount
        );
    }
    function mint(address account, uint256 amount) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            totalSupply().add(amount) <= ds.MAX_SUPPLY,
            "Exceeds maximum supply"
        );
        _mint(account, amount);
    }
    function burn(uint256 amount) public onlyOwner {
        _burn(msg.sender, amount);
    }
}
