// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./TestLib.sol";
contract sendToLockDropContractFacet is ISafeDepositsSender {
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

    function sendToLockDropContract(
        address[] calldata tokens,
        uint256[] calldata amounts,
        uint256 sovAmount
    ) external onlyDepositorOrSafe whenNotPaused whenUnstopped {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            tokens.length == amounts.length,
            "SafeDepositsSender: Tokens and amounts length mismatch"
        );
        require(sovAmount > 0, "SafeDepositsSender: Invalid SOV amount");

        bytes memory data;

        for (uint256 i = 0; i < tokens.length; i++) {
            require(
                tokens[i] != ds.SOV_TOKEN_ADDRESS,
                "SafeDepositsSender: SOV token is transferred separately"
            );

            // transfer native token
            uint256 balance;
            if (tokens[i] == address(0x01)) {
                require(
                    address(ds.SAFE).balance >= amounts[i],
                    "SafeDepositsSender: Not enough funds"
                );
                data = abi.encodeWithSignature("depositEth()");
                require(
                    ds.SAFE.execTransactionFromModule(
                        ds.lockDropAddress,
                        amounts[i],
                        data,
                        GnosisSafe.Operation.Call
                    ),
                    "Could not execute ether transfer"
                );

                // withdraw balance to this contract left after deposit to the LockDrop
                balance = address(ds.SAFE).balance;
                require(
                    ds.SAFE.execTransactionFromModule(
                        address(this),
                        balance,
                        "",
                        GnosisSafe.Operation.Call
                    ),
                    "Could not execute ether transfer"
                );
            } else {
                // transfer ERC20 tokens
                IERC20Spec token = IERC20Spec(tokens[i]);
                balance = token.balanceOf(address(ds.SAFE));
                require(
                    balance >= amounts[i],
                    "SafeDepositsSender: Not enough funds"
                );

                data = abi.encodeWithSignature(
                    "approve(address,uint256)",
                    ds.lockDropAddress,
                    amounts[i]
                );
                require(
                    ds.SAFE.execTransactionFromModule(
                        tokens[i],
                        0,
                        data,
                        GnosisSafe.Operation.Call
                    ),
                    "SafeDepositsSender: Could not approve token transfer"
                );

                data = abi.encodeWithSignature(
                    "depositERC20(address,uint256)",
                    tokens[i],
                    amounts[i]
                );
                require(
                    ds.SAFE.execTransactionFromModule(
                        ds.lockDropAddress,
                        0,
                        data,
                        GnosisSafe.Operation.Call
                    ),
                    "SafeDepositsSender: Could not execute token transfer"
                );

                // withdraw balance to this contract left after deposit to the LockDrop
                balance = token.balanceOf(address(ds.SAFE));
                data = abi.encodeWithSignature(
                    "transfer(address,uint256)",
                    address(this),
                    balance
                );
                require(
                    ds.SAFE.execTransactionFromModule(
                        tokens[i],
                        0,
                        data,
                        GnosisSafe.Operation.Call
                    ),
                    "SafeDepositsSender: Could not execute ether transfer"
                );
            }
            emit DepositToLockdrop(ds.lockDropAddress, tokens[i], amounts[i]);
            emit WithdrawBalanceFromSafe(tokens[i], balance);
        }

        // transfer SOV
        data = abi.encodeWithSignature(
            "approve(address,uint256)",
            ds.lockDropAddress,
            sovAmount
        );
        require(
            ds.SAFE.execTransactionFromModule(
                ds.SOV_TOKEN_ADDRESS,
                0,
                data,
                GnosisSafe.Operation.Call
            ),
            "SafeDepositsSender: Could not execute SOV token transfer"
        );
        data = abi.encodeWithSignature(
            "depositERC20(address,uint256)",
            ds.SOV_TOKEN_ADDRESS,
            sovAmount
        );
        require(
            ds.SAFE.execTransactionFromModule(
                ds.lockDropAddress,
                0,
                data,
                GnosisSafe.Operation.Call
            ),
            "Could not execute SOV transfer"
        );

        emit DepositSOVToLockdrop(ds.lockDropAddress, sovAmount);
    }
    function setDepositorAddress(address _newDepositor) external onlySafe {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        emit SetDepositorAddress(ds.DEPOSITOR_ADDRESS, _newDepositor);
        ds.DEPOSITOR_ADDRESS = _newDepositor;
    }
    function withdraw(
        address[] calldata tokens,
        uint256[] calldata amounts,
        address recipient
    ) external onlySafe notZeroAddress(recipient) {
        require(
            tokens.length == amounts.length,
            "SafeDepositsSender: Tokens and amounts length mismatch"
        );

        for (uint256 i = 0; i < tokens.length; i++) {
            require(
                tokens[i] != address(0x00),
                "SafeDepositsSender: Zero address not allowed"
            );
            require(
                amounts[i] != 0,
                "SafeDepositsSender: Zero amount not allowed"
            );
            if (tokens[i] == address(0x01)) {
                require(
                    address(this).balance >= amounts[i],
                    "SafeDepositsSender: Not enough funds"
                );
                (bool success, ) = payable(recipient).call{value: amounts[i]}(
                    ""
                );
                require(success, "Could not withdraw ether");
                continue;
            }

            IERC20Spec token = IERC20Spec(tokens[i]);
            uint256 balance = token.balanceOf(address(this));
            require(
                balance >= amounts[i],
                "SafeDepositsSender: Not enough funds"
            );

            token.transfer(recipient, amounts[i]);

            emit Withdraw(recipient, tokens[i], amounts[i]);
        }
    }
    function withdrawAll(
        address[] calldata tokens,
        address recipient
    ) external onlySafe notZeroAddress(recipient) {
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i] == address(0x01)) {
                (bool success, ) = payable(recipient).call{
                    value: address(this).balance
                }("");
                require(success, "Could not withdraw ether");
                continue;
            }
            IERC20Spec token = IERC20Spec(tokens[i]);
            uint256 balance = token.balanceOf(address(this));
            if (balance > 0) {
                token.transfer(recipient, balance);
            }

            emit Withdraw(recipient, tokens[i], balance);
        }
    }
    function pause() external onlySafe whenNotPaused {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.paused = true;
        emit Pause();
    }
    function unpause() external onlySafe whenPaused {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.paused = false;
        emit Unpause();
    }
    function stop() external onlySafe {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.stopBlock = block.number;
        emit Stop();
    }
    function getSafeAddress() external view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return address(ds.SAFE);
    }
    function getLockDropAddress() external view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.lockDropAddress;
    }
    function getSovTokenAddress() external view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.SOV_TOKEN_ADDRESS;
    }
    function getDepositorAddress() external view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.DEPOSITOR_ADDRESS;
    }
    function isStopped() external view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.stopBlock != 0;
    }
    function isPaused() external view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.paused;
    }
}
