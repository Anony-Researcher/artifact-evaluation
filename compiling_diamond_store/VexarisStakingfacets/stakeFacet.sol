// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;
import "./TestLib.sol";
contract stakeFacet is Ownable {
    using SafeMath for uint256;
    using LowGasSafeMath for uint32;
    using SafeERC20 for IERC20;
    using SafeERC20 for IxVexaris;

    event LogStake(address indexed recipient, uint256 amount);
    event LogRebase(uint256 distribute);
    event LogUnstake(address indexed recipient, uint256 amount);
    function stake(
        uint _amount,
        address _recipient,
        TestLib.LOCKUPS _lockup
    ) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        rebase();

        ds.Vexaris.safeTransferFrom(msg.sender, address(this), _amount);

        TestLib.Claim memory info = ds.warmupInfo[_recipient];
        require(!info.lock, "Deposits for account are locked");

        ds.warmupInfo[_recipient] = TestLib.Claim({
            deposit: info.deposit.add(_amount),
            gons: info.gons.add(ds.xVexaris.gonsForBalance(_amount)),
            expiry: ds.epoch.number.add(ds.warmupPeriod),
            lock: false
        });

        TestLib.Lockup memory lock = ds.lockupInfo[_recipient];
        require(
            lock.multiplier == 0 || _lockup == TestLib.LOCKUPS.NONE,
            "Account is already locked"
        );

        uint256 amountToTransfer = _amount;

        if (_lockup == TestLib.LOCKUPS.MONTH1) {
            // 1 - 1.25 Multiplier

            ds.lockupInfo[_recipient] = TestLib.Lockup({
                gonsWarmup: IxVexaris(ds.xVexaris).gonsForBalance(
                    _amount.mul(25).div(100)
                ),
                gonsAccount: IxVexaris(ds.xVexaris).gonsForBalance(_amount),
                initialDeposit: _amount,
                multiplier: 125,
                lockTimestamp: block.timestamp + ds.month
            });
            amountToTransfer = _amount.mul(125) / 100;
        }
        if (_lockup == TestLib.LOCKUPS.MONTH3) {
            // 2 - 1.5 Multiplier

            ds.lockupInfo[_recipient] = TestLib.Lockup({
                gonsWarmup: IxVexaris(ds.xVexaris).gonsForBalance(
                    _amount.mul(50).div(100)
                ),
                gonsAccount: IxVexaris(ds.xVexaris).gonsForBalance(_amount),
                initialDeposit: _amount,
                multiplier: 150,
                lockTimestamp: block.timestamp + ds.month * 3
            });

            amountToTransfer = _amount.mul(150).div(100);
        }
        if (_lockup == TestLib.LOCKUPS.MONTH6) {
            // 3 - 2 Multiplier

            ds.lockupInfo[_recipient] = TestLib.Lockup({
                gonsWarmup: IxVexaris(ds.xVexaris).gonsForBalance(_amount),
                gonsAccount: IxVexaris(ds.xVexaris).gonsForBalance(_amount),
                initialDeposit: _amount,
                multiplier: 200,
                lockTimestamp: block.timestamp + ds.month * 6
            });
            amountToTransfer = _amount * 2;
        }

        ds.xVexaris.safeTransfer(address(ds.warmupContract), amountToTransfer);
        emit LogStake(_recipient, _amount);
        return true;
    }
    function rebase() public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.epoch.endTime <= uint32(block.timestamp)) {
            ds.xVexaris.rebase(ds.epoch.distribute, ds.epoch.number);

            ds.epoch.endTime = ds.epoch.endTime.add32(ds.epoch.length);
            ds.epoch.number++;

            if (address(ds.distributor) != address(0)) {
                ds.distributor.distribute();
            }

            uint balance = contractBalance();
            uint staked = ds.xVexaris.circulatingSupply();

            if (balance <= staked) {
                ds.epoch.distribute = 0;
            } else {
                ds.epoch.distribute = balance.sub(staked);
            }
            emit LogRebase(ds.epoch.distribute);
        }
    }
    function unstake(uint _amount, bool _trigger) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_trigger) {
            rebase();
        }
        TestLib.Lockup memory lock = ds.lockupInfo[msg.sender];
        require(
            ds.xVexaris.balanceOf(msg.sender) - _amount >=
                ds.xVexaris.balanceForGons(lock.gonsAccount),
            "Not enough ds.xVexaris for lockup"
        );
        ds.xVexaris.safeTransferFrom(msg.sender, address(this), _amount);
        ds.Vexaris.safeTransfer(msg.sender, _amount);
        emit LogUnstake(msg.sender, _amount);
    }
    function unstakeLocked(bool _trigger) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_trigger) {
            rebase();
        }
        TestLib.Lockup memory lock = ds.lockupInfo[msg.sender];
        if (lock.multiplier > 0) {
            ds.xVexaris.safeTransferFrom(
                msg.sender,
                address(this),
                ds.xVexaris.balanceForGons(lock.gonsAccount)
            );
            ds.warmupContract.retrieve(
                address(this),
                ds.xVexaris.balanceForGons(lock.gonsWarmup)
            );

            if (lock.lockTimestamp <= block.timestamp) {
                ds.Vexaris.safeTransfer(
                    msg.sender,
                    ds.xVexaris.balanceForGons(
                        lock.gonsWarmup + lock.gonsAccount
                    )
                );
            } else {
                ds.Vexaris.safeTransfer(msg.sender, lock.initialDeposit);
            }
            delete ds.lockupInfo[msg.sender];
        }
    }
    function contractBalance() public view returns (uint) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.Vexaris.balanceOf(address(this)).add(ds.totalBonus);
    }
}
