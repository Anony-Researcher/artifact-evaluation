// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract safeMintFacet is ERC721Royalty, ERC721URIStorage {
    function safeMint(address to, string memory uri) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tokenId = ds._nextTokenId++;
        _safeMint(to, tokenId);

        string memory jsonFile = string(
            abi.encodePacked(
                uri,
                "metadata",
                Strings.toString(tokenId),
                ".json"
            )
        );
        _setTokenURI(tokenId, jsonFile);
    }
    function setTokenURI(uint256 tokenId, string memory uri) public onlyOwner {
        _setTokenURI(tokenId, uri);
    }
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721URIStorage, ERC721Royalty) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721URIStorage, ERC721) returns (string memory) {
        return super.tokenURI(tokenId);
    }
}
