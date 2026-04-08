// File: @openzeppelin/contracts@4.7.3/security/ReentrancyGuard.sol

// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract getEthereumBalanceFacet is ERC20 {
    function getEthereumBalance() external view returns (uint) {
        return address(this).balance;
    }
}
