/**
 */

// File: @openzeppelin/contracts/utils/Address.sol

// OpenZeppelin Contracts (last updated v4.8.0) (utils/Address.sol)

pragma solidity ^0.8.1;
import "./TestLib.sol";
contract _mintFacet {
    using SafeMath for uint256;
    using Address for address;

    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.notice, "Not allowed");
        _;
    }

    function _mint(address account, uint256 amount) internal virtual {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(account != address(0), "ERC20: mint to the zero address");
        ds._totalSupply = ds._totalSupply.add(amount);
        ds._balances[account] = ds._balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }
}
