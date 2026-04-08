// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract numberMintedFacet is ERC721A {
    function numberMinted(address owner) public view returns (uint256) {
        return _numberMinted(owner);
    }
}
