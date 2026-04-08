// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

interface ISafeDepositsSender {
    event Withdraw(address indexed from, address indexed token, uint256 amount);
    event DepositToLockdrop(
        address indexed lockDrop,
        address indexed token,
        uint256 amount
    );
    event DepositSOVToLockdrop(address indexed lockDrop, uint256 amount);
    event WithdrawBalanceFromSafe(address indexed token, uint256 balance);
    event Pause();
    event Unpause();
    event Stop();
    event SetDepositorAddress(
        address indexed oldDepositor,
        address indexed newDepositor
    );
    event SetLockDropAddress(
        address indexed oldLockDrop,
        address indexed newLockDrop
    );
    event MapDepositorToReceiver(
        address indexed depositor,
        address indexed receiver
    );

    function getSafeAddress() external view returns (address);
    function getLockDropAddress() external view returns (address);
    function getSovTokenAddress() external view returns (address);
    function getDepositorAddress() external view returns (address);
    function isStopped() external view returns (bool);
    function isPaused() external view returns (bool);

    // @note amount > 0 should be checked by the caller
    function withdraw(
        address[] calldata tokens,
        uint256[] calldata amounts,
        address recipient
    ) external;

    function withdrawAll(address[] calldata tokens, address recipient) external;

    function pause() external;

    function unpause() external;

    function stop() external;

    function setDepositorAddress(address _newDepositor) external;

    function sendToLockDropContract(
        address[] calldata tokens,
        uint256[] calldata amounts,
        uint256 sovAmount
    ) external;
}

interface IERC20Spec {
    function balanceOf(address _who) external view returns (uint256);
    function transfer(address _to, uint256 _value) external returns (bool);
}
interface GnosisSafe {
    enum Operation {
        Call,
        DelegateCall
    }

    /// @dev Allows a Module to execute a Safe transaction without any further confirmations.
    /// @param to Destination address of module transaction.
    /// @param value Ether value of module transaction.
    /// @param data Data payload of module transaction.
    /// @param operation Operation type of module transaction.
    function execTransactionFromModule(
        address to,
        uint256 value,
        bytes calldata data,
        Operation operation
    ) external returns (bool success);
}

/**
 * @title SafeDepositsSender
 * @notice This contract is a gateway for depositing funds into the Bob locker contracts
 */

address constant ETH_TOKEN_ADDRESS = address(0x01);

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        GnosisSafe SAFE;
        address SOV_TOKEN_ADDRESS;
        address DEPOSITOR_ADDRESS;
        address lockDropAddress;
        uint256 stopBlock;
        bool paused;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
