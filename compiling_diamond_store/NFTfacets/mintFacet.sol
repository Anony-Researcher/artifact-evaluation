// File: contracts/External/IERC721Receiver.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.4;
import "./TestLib.sol";
contract mintFacet is ERC721 {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.owner == msg.sender, "Ownable: caller is not the ds.owner");
        _;
    }

    function mint(uint256 tokenId, uint256 fee) public virtual {
        _safeMint(msg.sender, tokenId, fee);
    }
}
