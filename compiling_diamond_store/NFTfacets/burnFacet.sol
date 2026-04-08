// File: contracts/External/IERC721Receiver.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.4;
import "./TestLib.sol";
contract burnFacet is ERC721 {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.owner == msg.sender, "Ownable: caller is not the ds.owner");
        _;
    }

    function burn(uint256 tokenId) external {
        require(_exists(tokenId), "ERC721: nonexistent token");
        _burn(tokenId);
    }
}
