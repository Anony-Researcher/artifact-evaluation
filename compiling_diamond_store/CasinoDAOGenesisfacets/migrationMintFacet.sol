// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract migrationMintFacet is Ownable {
    using Strings for uint256;

    function migrationMint(
        address[] memory _wallets,
        uint256[] memory _tokenIDs
    ) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.admin[msg.sender] || msg.sender == owner(),
            "Only ds.admin or owner can execute."
        );
        require(
            _wallets.length == _tokenIDs.length,
            "Address not match with token ID length."
        );
        for (uint256 i = 0; i < _wallets.length; i++) {
            _safeMint(_wallets[i], _tokenIDs[i]);
        }
    }
}
