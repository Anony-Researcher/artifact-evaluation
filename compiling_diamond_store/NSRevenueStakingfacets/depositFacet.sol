//SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract depositFacet is DividendTracker {
    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    function deposit(uint256 _amount) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_amount > 0, "Zero Amount");

        if (ds.holderUnlockTime[msg.sender] == 0) {
            ds.holderUnlockTime[msg.sender] = block.timestamp + ds.lockDuration;
        }
        uint256 userAmount = holderBalance[msg.sender];

        uint256 amountTransferred = 0;

        uint256 initialBalance = ds.nsToken.balanceOf(address(this));
        ds.nsToken.transferFrom(address(msg.sender), address(this), _amount);
        amountTransferred =
            ds.nsToken.balanceOf(address(this)) -
            initialBalance;

        setBalance(payable(msg.sender), userAmount + amountTransferred);

        emit Deposit(msg.sender, _amount);
    }
    function withdraw(uint256 _amount) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_amount > 0, "Zero Amount");
        uint256 userAmount = holderBalance[msg.sender];
        require(_amount <= userAmount, "Not enough tokens");
        require(
            ds.holderUnlockTime[msg.sender] <= block.timestamp,
            "May not withdraw early"
        );

        ds.nsToken.transfer(address(msg.sender), _amount);

        setBalance(payable(msg.sender), userAmount - _amount);

        if (userAmount > 0) {
            ds.holderUnlockTime[msg.sender] = block.timestamp + ds.lockDuration;
        } else {
            ds.holderUnlockTime[msg.sender] = 0;
        }

        emit Withdraw(msg.sender, _amount);
    }
    function withdrawAll() public nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 userAmount = holderBalance[msg.sender];
        require(userAmount > 0, "Not a holder");
        require(
            ds.holderUnlockTime[msg.sender] <= block.timestamp,
            "May not withdraw early"
        );

        ds.nsToken.transfer(address(msg.sender), userAmount);

        setBalance(payable(msg.sender), 0);
        ds.holderUnlockTime[msg.sender] = 0;

        emit Withdraw(msg.sender, userAmount);
    }
    function claim() external nonReentrant {
        processAccount(payable(msg.sender), false);
    }
    function compound(uint256 minOutput) external nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 userAmount = holderBalance[msg.sender];
        uint256 amountEthForCompound = _withdrawDividendOfUserForCompound(
            payable(msg.sender)
        );
        if (amountEthForCompound > 0) {
            uint256 initialBalance = ds.nsToken.balanceOf(address(this));
            buyBackTokens(amountEthForCompound, minOutput);
            uint256 amountTransferred = ds.nsToken.balanceOf(address(this)) -
                initialBalance;
            setBalance(payable(msg.sender), userAmount + amountTransferred);
        } else {
            revert("No rewards");
        }
    }
    function _withdrawDividendOfUserForCompound(
        address payable user
    ) internal returns (uint256 _withdrawableDividend) {
        _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] =
                withdrawnDividends[user] +
                _withdrawableDividend;
            emit DividendWithdrawn(user, _withdrawableDividend);
        }
    }
    function buyBackTokens(uint256 ethAmountInWei, uint256 minOut) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // generate the uniswap pair path of weth -> eth
        address[] memory path = new address[](2);
        path[0] = ds.dexRouter.WETH();
        path[1] = address(ds.nsToken);

        // make the swap
        ds.dexRouter.swapExactETHForTokensSupportingFeeOnTransferTokens{
            value: ethAmountInWei
        }(minOut, path, address(this), block.timestamp);
    }
}
