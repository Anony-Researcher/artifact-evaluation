// SPDX-License-Identifier: MIT
// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract setBaseURIFacet {
    using Strings for uint256;

    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.baseURI = _newBaseURI;
    }
    function manageAdmin(address wallet, bool _state) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.admin[wallet] = _state;
    }
}
