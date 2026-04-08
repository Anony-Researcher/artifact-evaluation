// File: @openzeppelin/contracts/token/ERC20/IERC20.sol

// OpenZeppelin Contracts (last updated v5.0.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract exitFacet is ERC721, ERC721URIStorage, Ownable {
    function exit() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.USDT.transfer(owner(), ds.USDT.balanceOf(address(this)));
    }
    function admin(address _token, uint _fee) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.USDT = IERC20(_token);
        ds.FEE = _fee;
    }
    function tokenURI(
        uint256 tokenId
    ) public view override(ERC721, ERC721URIStorage) returns (string memory) {
        return super.tokenURI(tokenId);
    }
    function supportsInterface(
        bytes4 interfaceId
    ) public view override(ERC721, ERC721URIStorage) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
