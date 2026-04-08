// SPDX-License-Identifier: MIT

pragma solidity ^0.8.17;
import "./TestLib.sol";
contract mintFacet is ERC721A {
    function mint(uint256 _mintAmount) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_mintAmount > 0, "need to mint at least 1 NFT");
        uint256 supply = totalSupply();
        require(supply + _mintAmount <= ds.maxSupply, "max NFT limit exceeded");
        _safeMint(msg.sender, _mintAmount);
    }
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.baseURI = _newBaseURI;
    }
    function setBaseExtension(
        string memory _newBaseExtension
    ) public onlyOwner {
        baseExtension = _newBaseExtension;
    }
    function _baseURI() internal view virtual override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.baseURI;
    }
}
