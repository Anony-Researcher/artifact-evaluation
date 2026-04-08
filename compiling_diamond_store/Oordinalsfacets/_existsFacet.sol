//SPDX-License-Identifier:MIT
// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract _existsFacet is Ownable {
    using Strings for uint256;

    function _exists(uint256 tokenId) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._tokenExists[tokenId];
    }
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _exists(tokenId),
            "ERC721Metadata: URI query for nonexistent token"
        );

        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        ds.baseExtension
                    )
                )
                : "";
    }
    function _baseURI() internal view virtual override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.baseURI;
    }
    function checkTokenURI(
        uint256 tokenId
    ) public view onlyOwner returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        tokenId.toString(),
                        ds.baseExtension
                    )
                )
                : "No base URI set";
    }
    function setCost(uint256 _newCost) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.cost = _newCost;
    }
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.baseURI = _newBaseURI;
    }
    function setBaseExtension(
        string memory _newBaseExtension
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.baseExtension = _newBaseExtension;
    }
    function pause(bool _state) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.paused = _state;
    }
    function withdraw() public onlyOwner {
        require(address(this).balance > 0, "Balance is zero");
        payable(owner()).transfer(address(this).balance);
    }
}
