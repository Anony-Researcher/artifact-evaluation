// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// +++++++++++++++++++++++************+++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++#@@@@@@@@@@@@%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*++++++++++++++++++++++
// ++++++++++++++++++++++#@@@@@@@@@@@@%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*++++++++++++++++++++++
// ++++++++++++++++++++++#@@@@@@@@@@@@%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%*++++++++++++++++++++++
// ++++++++++++++++%%%%%%@@@@@@@%%%%%%%%%+............=%%%%%#......+%%#######++++++++++++++++
// ++++++++++++++++%@@@@@@@@@@@@%%%*+++++-            =%%%%%#      =+++++*%%#++++++++++++++++
// ++++++++++++++++%@@@@@@@@@@@@%%%:                  =%%%%%#            :%%#++++++++++++++++
// ++++++++++++++++%@@@@@@@@@@@@%%%:                  =%%%%%#            :%%#++++++++++++++++
// ++++++++++++++++%@@@@@@@@@@@@%%%:               ...=######            :%%#++++++++++++++++
// ++++++++++++++++%@@@@@@@@@@@@%%%:               +##+---------.        :%%#++++++++++++++++
// ++++++++++++++++%@@@@@@@@@@@@%%%:               +##+---------.        :%%#++++++++++++++++
// ++++++++++++++++%@@@@@@@@@@@@%%%:               +##+---------.        :%%#++++++++++++++++
// ++++++++++++++++%@@@@@@@@@@@@%%%:        .###   +##+---------.  +##=  :%%#++++++++++++++++
// ++++++++++++++++%@@@@@@@@@@@@%%%:        .***   =++=:::::::::   =**=  :%%#++++++++++++++++
// ++++++++++++++++%@@@@@@@@@@@@%%%:                                     :%%#++++++++++++++++
// ++++++++++++++++%@@@@@@@@@@@@%%%:                                     :%%#++++++++++++++++
// ++++++++++++++++%@@@@@@@@@@@@%%%:                                     :%%#++++++++++++++++
// ++++++++++++++++%@@@@@@@@@@@@%%%:                                     :%%#++++++++++++++++
// ++++++++++++++++%@@@@@@@@@@@@%%%=-------------------------------------=%%#++++++++++++++++
// ++++++++++++++++%@@@@@@@@@@@@%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%#++++++++++++++++
// ++++++++++++++++*********************************************************+++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
// ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "./TestLib.sol";
contract baseURIFacet is ERC721A, ERC2981, Ownable {
    using Strings for uint256;

    modifier isNotBlankURI(string memory _uri) {
        if (bytes(_uri).length == 0) {
            revert PENGU_BLANK_URI();
        }
        _;
    }
    modifier checkZeroAddress(address _address) {
        if (_address == address(0)) {
            revert PENGU_ZERO_ADDRESS();
        }
        _;
    }
    modifier checkZeroPrice(uint256 _price) {
        if (_price == 0) {
            revert PENGU_ZERO_PRICE();
        }
        _;
    }
    modifier isNotPaused() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.saleConfig == TestLib.SaleConfig.PAUSED) {
            revert PENGU_MINT_PAUSED();
        }
        _;
    }
    modifier isWLSale() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.saleConfig != TestLib.SaleConfig.WL) {
            revert PENGU_WL_OG_MINT_NOT_ACTIVE();
        }
        _;
    }
    modifier isPublicSale() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.saleConfig != TestLib.SaleConfig.MINT) {
            revert PENGU_PUBLIC_MINT_NOT_ACTIVE();
        }
        _;
    }
    modifier onlyTokenOwner(uint256 tokenId) {
        if (ownerOf(tokenId) != msg.sender) {
            revert PENGU_NOT_A_TOKEN_OWNER();
        }
        _;
    }
    modifier hasFreeClaim() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.numberOfFreeMint + 1 > FREE_MINT_RESERVE) {
            revert PENGU_FREE_CLAIM_LIMIT_REACHED();
        }

        _;
    }
    modifier hasWlClaimLeft(uint256 _amount) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.numberOfWlMint + _amount > WL_MINT_RESERVE) {
            revert PENGU_WL_CLAIM_LIMIT_REACHED();
        }

        _;
    }
    modifier alreadyClaimed() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.claimed[msg.sender] + 1 > ds.claim_limit) {
            revert PENGU_FREE_MINT_ALREADY_CLAIMED();
        }
        _;
    }
    modifier alreadyWlClaimed(uint256 _amount) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (ds.wl_claimed[msg.sender] + _amount > ds.wl_claim_limit) {
            revert PENGU_WL_MINT_ALREADY_CLAIMED();
        }
        _;
    }
    modifier isInMintTransactionLimit(uint256 _amount) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_amount > ds.tx_limit) {
            revert PENGU_MINT_TRANSACTION_LIMIT_REACHED();
        }
        _;
    }

    function baseURI(uint256 tokenId) internal view returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        TestLib.MetaType metadataType = ds.metaType[tokenId];
        if (!ds.revealed) {
            return ds.unRevealedURI;
        }

        if (metadataType == TestLib.MetaType.TYPE1) {
            return ds.metadataBaseURI;
        }
        return ds.metadataTwoBaseURI;
    }
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        if (!_exists(tokenId)) {
            revert PENGU_NONEXISTENT_TOKEN();
        }

        string memory baseMetadataURI = baseURI(tokenId);
        return
            bytes(baseMetadataURI).length > 0
                ? string(
                    abi.encodePacked(
                        baseMetadataURI,
                        tokenId.toString(),
                        baseExtension
                    )
                )
                : "";
    }
    function setRoyalty(
        address _receiver,
        uint96 _royaltyFeeInBips
    ) public onlyOwner checkZeroAddress(_receiver) {
        _setDefaultRoyalty(_receiver, _royaltyFeeInBips);
    }
    function setSaleConfigToMint() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.saleConfig = TestLib.SaleConfig.MINT;
    }
    function setSaleConfigToPause() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.saleConfig = TestLib.SaleConfig.PAUSED;
    }
    function setSaleConfigToWLMint() external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.saleConfig = TestLib.SaleConfig.WL;
    }
    function setReveal(bool value) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.revealed = value;
    }
    function setUnRevealedUri(
        string memory _unRevealedUri
    ) public onlyOwner isNotBlankURI(_unRevealedUri) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.unRevealedURI = _unRevealedUri;
    }
    function setMetaDataURI(
        string calldata _metadataBaseURI
    ) external onlyOwner isNotBlankURI(_metadataBaseURI) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.metadataBaseURI = _metadataBaseURI;
    }
    function setMintPrice(
        uint256 _price
    ) external onlyOwner checkZeroPrice(_price) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.mint_price = _price;
    }
    function setMintPriceDiscounted(
        uint256 _price
    ) external onlyOwner checkZeroPrice(_price) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.mint_price_discounted = _price;
    }
    function setMetaDataTwoURI(
        string calldata _metadataTwoBaseURI
    ) external onlyOwner isNotBlankURI(_metadataTwoBaseURI) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.metadataTwoBaseURI = _metadataTwoBaseURI;
    }
    function setMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_merkleRoot.length == 0) {
            revert PENGU_INVALID_MERKLE_ROOT();
        }
        ds.merkleRoot = _merkleRoot;
    }
    function setWLMerkleRoot(bytes32 _merkleRoot) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (_merkleRoot.length == 0) {
            revert PENGU_INVALID_MERKLE_ROOT();
        }
        ds.wl_merkleRoot = _merkleRoot;
    }
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721A, ERC2981) returns (bool) {
        return
            ERC721A.supportsInterface(interfaceId) ||
            ERC2981.supportsInterface(interfaceId);
    }
    function withdrawFunds() external onlyOwner {
        if (address(this).balance == 0) {
            revert PENGU_NO_FUNDS_TO_WITHDRAW();
        }
        (bool success, ) = owner().call{value: address(this).balance}("");
        if (!success) {
            revert PENGU_WITHDRAWAL_FAILED();
        }
    }
}
