// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract getAccountDepositsFacet {
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    function getAccountDeposits(
        address _account,
        string memory _symbol
    ) public view returns (uint256[] memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.AccountDeposits[_account][_symbol];
    }
}
