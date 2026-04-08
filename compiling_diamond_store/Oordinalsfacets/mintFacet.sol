//SPDX-License-Identifier:MIT
// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract mintFacet is ERC721Enumerable, Ownable {
    using Strings for uint256;

    function mint(uint256 _mintAmount) public payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 supply = totalSupply();
        require(!ds.paused);
        require(_mintAmount > 0);

        require(supply + _mintAmount <= ds.maxSupply);

        if (msg.sender != owner()) {
            require(msg.value >= ds.cost * _mintAmount, "Insufficient funds");
        }

        for (uint256 i = 1; i <= _mintAmount; i++) {
            uint256 newTokenId = supply + i;
            _safeMint(msg.sender, newTokenId);
            ds._tokenExists[newTokenId] = true;
        }
    }
}
