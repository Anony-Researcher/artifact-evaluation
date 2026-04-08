// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract showQualifiedAddressesFacet {
    function showQualifiedAddresses()
        external
        view
        returns (address[200] memory)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.airdropQualifiedAddresses;
    }
}
