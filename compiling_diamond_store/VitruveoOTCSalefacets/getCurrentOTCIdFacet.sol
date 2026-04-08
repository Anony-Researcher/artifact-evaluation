// File: @openzeppelin/contracts/utils/ReentrancyGuard.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract getCurrentOTCIdFacet {
    using SafeERC20 for IERC20;
    using Counters for Counters.Counter;

    function getCurrentOTCId() external view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.nextSaleId.current();
    }
}
