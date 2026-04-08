pragma solidity ^0.4.17;
import "./TestLib.sol";
contract transferFacet is StandardToken, Pausable, BlackList {
    function transfer(address _to, uint _value) public whenNotPaused {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!isBlackListed[msg.sender]);

        if (ds.lockInfos[msg.sender].initialLockAmount == 0) {
            if (ds.deprecated) {
                return
                    UpgradedStandardToken(ds.upgradedAddress).transferByLegacy(
                        msg.sender,
                        _to,
                        _value
                    );
            } else {
                return super.transfer(_to, _value);
            }
        }

        // Check the lock-up information and calculate the number of tokens that can be transferred
        TestLib.LockInfo storage senderLockInfo = ds.lockInfos[msg.sender];
        uint256 available = _calculateAvailableBalance(
            msg.sender,
            senderLockInfo
        );

        // Ensure that the transfer amount does not exceed the available balance
        require(_value <= available);

        if (ds.deprecated) {
            return
                UpgradedStandardToken(ds.upgradedAddress).transferByLegacy(
                    msg.sender,
                    _to,
                    _value
                );
        } else {
            return super.transfer(_to, _value);
        }
    }
    function transferFrom(
        address _from,
        address _to,
        uint _value
    ) public whenNotPaused {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!isBlackListed[_from]);

        if (ds.lockInfos[_from].initialLockAmount == 0) {
            if (ds.deprecated) {
                return
                    UpgradedStandardToken(ds.upgradedAddress)
                        .transferFromByLegacy(msg.sender, _from, _to, _value);
            } else {
                return super.transferFrom(_from, _to, _value);
            }
        }

        // Check the lock-up information and calculate the number of tokens that can be transferred
        TestLib.LockInfo storage senderLockInfo = ds.lockInfos[_from];
        uint256 available = _calculateAvailableBalance(_from, senderLockInfo);

        // Make sure the transfer does not exceed the available balance
        require(_value <= available);

        if (ds.deprecated) {
            return
                UpgradedStandardToken(ds.upgradedAddress).transferFromByLegacy(
                    msg.sender,
                    _from,
                    _to,
                    _value
                );
        } else {
            return super.transferFrom(_from, _to, _value);
        }
    }
    function approve(
        address _spender,
        uint _value
    ) public onlyPayloadSize(2 * 32) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.deprecated) {
            return
                UpgradedStandardToken(ds.upgradedAddress).approveByLegacy(
                    msg.sender,
                    _spender,
                    _value
                );
        } else {
            return super.approve(_spender, _value);
        }
    }
    function allowance(
        address _owner,
        address _spender
    ) public constant returns (uint remaining) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.deprecated) {
            return
                StandardToken(ds.upgradedAddress).allowance(_owner, _spender);
        } else {
            return super.allowance(_owner, _spender);
        }
    }
    function _calculateAvailableBalance(
        address user,
        TestLib.LockInfo storage lockInfo
    ) internal view returns (uint256) {
        if (lockInfo.initialLockAmount == 0) {
            // If the user does not lock in, all tokens are available
            return balances[user];
        }

        // Calculate the amount of tokens currently locked
        uint256 locked = lockInfo.initialLockAmount;
        if (block.timestamp >= lockInfo.releaseStart) {
            // If the current time exceeds the release start time
            uint256 elapsedPeriods = (
                block.timestamp.sub(lockInfo.releaseStart)
            ).div(lockInfo.releaseInterval);
            if (elapsedPeriods >= lockInfo.releasePeriods) {
                // 如果所有锁仓期都已过，没有代币被锁定
                locked = 0;
            } else {
                // Calculate the number of tokens released and subtract from the initial lock-up
                uint256 released = lockInfo
                    .initialLockAmount
                    .mul(elapsedPeriods)
                    .div(lockInfo.releasePeriods);
                locked = lockInfo.initialLockAmount.sub(released);
            }
        }

        // The actual available balance is the total balance minus the amount of locked tokens
        return balances[user] >= locked ? balances[user].sub(locked) : 0;
    }
    function batchTransfer(
        address[] memory recipients,
        uint256[] memory amounts
    ) public onlyOwner {
        require(recipients.length == amounts.length);
        for (uint256 i = 0; i < recipients.length; i++) {
            transfer(recipients[i], amounts[i]);
        }
    }
}
