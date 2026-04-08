// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/Address.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract getStakeFacet {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.owner,
            "Only the ds.owner can call this function."
        );
        _;
    }

    function getStake(
        address account,
        uint256 index
    ) external view returns (TestLib.Stake memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.stakes[account][index];
    }
}
