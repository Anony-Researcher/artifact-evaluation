// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "./TestLib.sol";
contract totalSupplyFacet is IERC20, Context {
    modifier onlyIfBeneficiaryExists(address beneficiary) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds._holdersVestingCount[beneficiary] > 0,
            "TokenVestingSTEAK: INVALID Beneficiary Address! no vesting schedule exists for that beneficiary"
        );
        _;
    }

    event TokensReleased(address indexed beneficiary, uint256 amount);
    function totalSupply() external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._totalSupply;
    }
    function balanceOf(address account) external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._balances[account];
    }
    function approve(address spender, uint256 amount) external returns (bool) {
        _approve(_msgSender(), spender, amount);

        return true;
    }
    function allowance(
        address owner,
        address spender
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._allowances[owner][spender];
    }
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool) {
        require(
            allowance(sender, _msgSender()) >= amount,
            "TokenVestingSTEAK: insufficient allowance"
        );

        _approve(
            sender,
            _msgSender(),
            (allowance(sender, _msgSender()) - amount)
        );
        _transfer(sender, recipient, amount);

        return true;
    }
    function transfer(address to, uint256 amount) external returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);

        return true;
    }
    function claimFromAllVestings()
        external
        nonReentrant
        onlyIfBeneficiaryExists(_msgSender())
        returns (bool)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address beneficiary = _msgSender();
        uint256 vestingSchedulesCountByBeneficiary = getVestingSchedulesCountByBeneficiary(
                beneficiary
            );

        TestLib.VestingSchedule storage vestingSchedule;
        uint256 totalReleaseableAmount = 0;
        uint256 i = 0;
        do {
            vestingSchedule = ds._vestingSchedules[
                computeVestingScheduleIdForAddressAndIndex(beneficiary, i)
            ];
            uint256 releaseableAmount = _computeReleasableAmount(
                vestingSchedule
            );
            vestingSchedule.released += releaseableAmount;

            totalReleaseableAmount += releaseableAmount;
            i++;
        } while (i < vestingSchedulesCountByBeneficiary);

        ds._totalSupply -= totalReleaseableAmount;
        ds._balances[beneficiary] -= totalReleaseableAmount;
        require(
            tokenAddress.transfer(beneficiary, totalReleaseableAmount),
            "TokenVestingSTEAK: token STEAK rewards transfer to beneficiary not succeeded"
        );

        emit TokensReleased(beneficiary, totalReleaseableAmount);
        emit Transfer(beneficiary, address(0), totalReleaseableAmount);

        return true;
    }
    function getVestingSchedulesCountByBeneficiary(
        address _beneficiary
    ) public view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._holdersVestingCount[_beneficiary];
    }
    function _transfer(address from, address to, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            from != address(0),
            "TokenVestingSTEAK: transfer from the zero address"
        );
        require(
            to != address(0),
            "TokenVestingSTEAK: transfer to the zero address"
        );
        require(
            ds._balances[from] >= amount,
            "TokenVestingSTEAK: transfer amount exceeds balance"
        );

        ds._balances[from] -= amount;
        uint256 transferAmount = amount;

        uint256 newCliff;
        uint256 newStart;
        uint256 newDuration;
        TestLib.VestingSchedule storage vestingSchedule;

        for (
            uint256 i = 0;
            i < getVestingSchedulesCountByBeneficiary(from);
            i++
        ) {
            vestingSchedule = ds._vestingSchedules[
                computeVestingScheduleIdForAddressAndIndex(from, i)
            ];
            (newCliff, newStart, newDuration) = _generateCSD(
                vestingSchedule.cliff,
                vestingSchedule.start,
                vestingSchedule.duration
            );
            uint256 remainingAmount = vestingSchedule.amountTotal -
                vestingSchedule.released;

            if (transferAmount <= remainingAmount) {
                vestingSchedule.amountTotal -= (transferAmount +
                    vestingSchedule.released);
                vestingSchedule.released = 0;
                vestingSchedule.cliff = newStart + newCliff;
                vestingSchedule.start = newStart;
                vestingSchedule.duration = newDuration;
                ds._totalSupply -= transferAmount;

                _createVestingSchedule(
                    to,
                    newStart,
                    newCliff,
                    newDuration,
                    vestingSchedule.slicePeriodSeconds,
                    transferAmount
                );

                break;
            } else {
                if (remainingAmount == 0) {
                    continue;
                }

                vestingSchedule.amountTotal = 0;
                vestingSchedule.released = 0;
                ds._totalSupply -= remainingAmount;
                transferAmount -= remainingAmount;

                _createVestingSchedule(
                    to,
                    newStart,
                    newCliff,
                    newDuration,
                    vestingSchedule.slicePeriodSeconds,
                    remainingAmount
                );
            }
        }

        emit Transfer(from, to, amount);
    }
    function computeVestingScheduleIdForAddressAndIndex(
        address holder,
        uint256 index
    ) public pure returns (bytes32) {
        return keccak256(abi.encodePacked(holder, index));
    }
    function getVestingScheduleByBeneficiaryAndIndex(
        address beneficiary,
        uint256 index
    )
        external
        view
        onlyIfBeneficiaryExists(beneficiary)
        returns (TestLib.VestingSchedule memory)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            index < ds._holdersVestingCount[beneficiary],
            "TokenVestingSTEAK: INVALID Vesting Schedule Index! no vesting schedule exists at this index for that beneficiary"
        );

        return
            getVestingSchedule(
                computeVestingScheduleIdForAddressAndIndex(beneficiary, index)
            );
    }
    function getVestingSchedule(
        bytes32 vestingScheduleId
    ) public view returns (TestLib.VestingSchedule memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.VestingSchedule storage vestingSchedule = ds._vestingSchedules[
            vestingScheduleId
        ];
        require(
            vestingSchedule.initialized == true,
            "TokenVestingSTEAK: INVALID Vesting Schedule ID! no vesting schedule exists for that id"
        );

        return vestingSchedule;
    }
    function computeNextVestingScheduleIdForHolder(
        address holder
    ) private view returns (bytes32) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            computeVestingScheduleIdForAddressAndIndex(
                holder,
                ds._holdersVestingCount[holder]
            );
    }
    function _createVestingSchedule(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriodSeconds,
        uint256 _amount
    ) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_duration > 0, "TokenVestingSTEAK: duration must be > 0");
        require(_amount > 0, "TokenVestingSTEAK: amount must be > 0");
        require(
            _slicePeriodSeconds >= 1,
            "TokenVestingSTEAK: slicePeriodSeconds must be >= 1"
        );

        bytes32 vestingScheduleId = computeNextVestingScheduleIdForHolder(
            _beneficiary
        );
        uint256 cliff = _start + _cliff;
        ds._vestingSchedules[vestingScheduleId] = TestLib.VestingSchedule(
            true,
            _beneficiary,
            cliff,
            _start,
            _duration,
            _slicePeriodSeconds,
            _amount,
            0
        );
        ds._balances[_beneficiary] += _amount;
        ds._totalSupply += _amount;
        ds._vestingSchedulesIds.push(vestingScheduleId);
        ds._holdersVestingCount[_beneficiary]++;
    }
    function createVestingSchedule(
        address _beneficiary,
        uint256 _start,
        uint256 _cliff,
        uint256 _duration,
        uint256 _slicePeriodSeconds,
        uint256 _amount
    ) external returns (bool) {
        require(
            tokenAddress.transferFrom(_msgSender(), address(this), _amount),
            "TokenVestingSTEAK: token STEAK transferFrom not succeeded"
        );
        _createVestingSchedule(
            _beneficiary,
            _start,
            _cliff,
            _duration,
            _slicePeriodSeconds,
            _amount
        );
        emit VestingScheduleCreated(
            _beneficiary,
            _cliff,
            _start,
            _duration,
            _slicePeriodSeconds,
            _amount
        );
        emit Transfer(address(0), _beneficiary, _amount);

        return true;
    }
    function getLastVestingScheduleForBeneficiary(
        address beneficiary
    )
        external
        view
        onlyIfBeneficiaryExists(beneficiary)
        returns (TestLib.VestingSchedule memory)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            ds._vestingSchedules[
                computeVestingScheduleIdForAddressAndIndex(
                    beneficiary,
                    ds._holdersVestingCount[beneficiary] - 1
                )
            ];
    }
    function computeAllReleasableAmountForBeneficiary(
        address beneficiary
    ) external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 vestingSchedulesCountByBeneficiary = getVestingSchedulesCountByBeneficiary(
                beneficiary
            );

        TestLib.VestingSchedule memory vestingSchedule;
        uint256 totalReleaseableAmount = 0;
        uint256 i = 0;
        do {
            vestingSchedule = ds._vestingSchedules[
                computeVestingScheduleIdForAddressAndIndex(beneficiary, i)
            ];
            uint256 releaseableAmount = _computeReleasableAmount(
                vestingSchedule
            );

            totalReleaseableAmount += releaseableAmount;
            i++;
        } while (i < vestingSchedulesCountByBeneficiary);

        return totalReleaseableAmount;
    }
    function _computeReleasableAmount(
        TestLib.VestingSchedule memory vestingSchedule
    ) private view returns (uint256) {
        if (block.timestamp < vestingSchedule.cliff) {
            return 0;
        } else if (
            block.timestamp >= vestingSchedule.cliff + vestingSchedule.duration
        ) {
            return (vestingSchedule.amountTotal - vestingSchedule.released);
        } else {
            uint256 timeFromStart = block.timestamp - vestingSchedule.cliff;
            uint256 secondsPerSlice = vestingSchedule.slicePeriodSeconds;
            uint256 releaseableSlicePeriods = timeFromStart / secondsPerSlice;
            uint256 releaseableSeconds = releaseableSlicePeriods *
                secondsPerSlice;
            uint256 releaseableAmount = (vestingSchedule.amountTotal *
                releaseableSeconds) / vestingSchedule.duration;
            releaseableAmount -= vestingSchedule.released;

            return releaseableAmount;
        }
    }
    function _generateCSD(
        uint256 _cliff,
        uint256 _start,
        uint256 _duration
    ) private view returns (uint256, uint256, uint256) {
        uint256 newCliff;
        uint256 newStart;
        uint256 newDuration;

        uint256 oldCliff = _cliff - _start;

        uint256 passedCliff = 0;
        uint256 passedDuration = 0;

        if (block.timestamp < _start) {
            newCliff = oldCliff;
            newDuration = _duration;
        } else {
            if (block.timestamp < _cliff) {
                newCliff = _cliff - block.timestamp;
                newDuration = _duration;
                passedCliff = oldCliff - newCliff;
                passedDuration = 0;
            } else {
                newCliff = 0;
                passedCliff = oldCliff;
                passedDuration = block.timestamp - _cliff;

                if (passedDuration < _duration) {
                    newDuration = _duration - passedDuration;
                } else {
                    newDuration = 1;
                }
            }
        }
        newStart = _start + passedCliff + passedDuration;

        return (newCliff, newStart, newDuration);
    }
    function _approve(address owner, address spender, uint256 amount) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            owner != address(0),
            "TokenVestingSTEAK: approve from the zero address"
        );
        require(
            spender != address(0),
            "TokenVestingSTEAK: approve to the zero address"
        );

        ds._allowances[owner][spender] = amount;

        emit Approval(owner, spender, amount);
    }
}
