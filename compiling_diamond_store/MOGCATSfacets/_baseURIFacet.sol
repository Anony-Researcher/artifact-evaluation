// SPDX-License-Identifier: MIT

// File: @openzeppelin/contracts/utils/introspection/IERC165.sol

// OpenZeppelin Contracts (last updated v5.0.0) (utils/introspection/IERC165.sol)

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract _baseURIFacet is ERC721A, ERC2981 {
    function _baseURI() internal view virtual override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.baseURI;
    }
    function _startTokenId() internal view virtual override returns (uint256) {
        return 1;
    }
    function mint(uint256 tokens) public payable nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.paused, "Sale is ds.paused");
        require(_msgSenderERC721A() == tx.origin, "BOTS Are not Allowed");
        require(ds.publicSale, "Public Sale Hasn't started yet");
        require(totalSupply() + tokens <= ds.maxSupply, "Soldout");
        require(msg.value >= ds.cost * tokens, "insufficient funds");

        ds.PublicMintofUser[_msgSenderERC721A()] += tokens;
        _safeMint(_msgSenderERC721A(), tokens);
    }
    function presalemint(
        uint256 tokens,
        bytes32[] calldata merkleProof
    ) public payable nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.paused, "Sale is ds.paused");
        require(ds.preSale, "Presale Hasn't started yet");
        require(_msgSenderERC721A() == tx.origin, "BOTS Are not Allowed");
        require(
            MerkleProof.verify(
                merkleProof,
                ds.WLmerkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "You are not Whitelisted"
        );
        require(
            totalSupply() + tokens <= ds.maxSupply,
            "Whitelist MaxSupply exceeded"
        );
        uint256 pricetoPay = 0;
        if (ds.WhitelistedMintofUser[_msgSenderERC721A()] > ds.wlFree) {
            pricetoPay = tokens;
        } else {
            uint256 freeAllocation = ds.wlFree -
                ds.WhitelistedMintofUser[_msgSenderERC721A()];

            if (freeAllocation > 0) {
                if (freeAllocation >= tokens) {
                    pricetoPay = 0;
                } else {
                    pricetoPay = tokens - freeAllocation;
                }
            } else {
                pricetoPay = tokens;
            }
        }

        require(msg.value >= ds.wlcost * pricetoPay, "insufficient funds");

        ds.WhitelistedMintofUser[_msgSenderERC721A()] += tokens;
        _safeMint(_msgSenderERC721A(), tokens);
    }
    function ogmint(
        uint256 tokens,
        bytes32[] calldata merkleProof
    ) public payable nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(!ds.paused, "Sale is ds.paused");
        require(ds.ogSale, "OGsale Hasn't started yet");
        require(_msgSenderERC721A() == tx.origin, "BOTS Are not Allowed");
        require(
            MerkleProof.verify(
                merkleProof,
                ds.OGmerkleRoot,
                keccak256(abi.encodePacked(msg.sender))
            ),
            "You are not Whitelisted"
        );
        require(
            totalSupply() + tokens <= ds.maxSupply,
            "Whitelist MaxSupply exceeded"
        );
        uint256 pricetoPay = 0;
        if (ds.OGMintofUser[_msgSenderERC721A()] > ds.ogFree) {
            pricetoPay = tokens;
        } else {
            uint256 freeAllocation = ds.ogFree -
                ds.OGMintofUser[_msgSenderERC721A()];

            if (freeAllocation > 0) {
                if (freeAllocation >= tokens) {
                    pricetoPay = 0;
                } else {
                    pricetoPay = tokens - freeAllocation;
                }
            } else {
                pricetoPay = tokens;
            }
        }

        require(msg.value >= ds.ogcost * pricetoPay, "insufficient funds");

        ds.OGMintofUser[_msgSenderERC721A()] += tokens;
        _safeMint(_msgSenderERC721A(), tokens);
    }
    function airdrop(
        uint256 _mintAmount,
        address[] calldata destination
    ) public onlyOwner nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 totalnft = _mintAmount * destination.length;
        require(
            totalSupply() + totalnft <= ds.maxSupply,
            "max NFT limit exceeded"
        );
        for (uint256 i = 0; i < destination.length; i++) {
            _safeMint(destination[i], _mintAmount);
        }
    }
    function burn(uint256[] calldata tokenID) public nonReentrant {
        for (uint256 id = 0; id < tokenID.length; id++) {
            require(_exists(tokenID[id]), "Burning for nonexistent token");
            require(
                ownerOf(tokenID[id]) == _msgSenderERC721A(),
                "You are not owner of this NFT"
            );
            _burn(tokenID[id]);
        }
    }
    function tokenURI(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            _exists(tokenId),
            "ERC721AMetadata: URI query for nonexistent token"
        );

        if (ds.revealed == false) {
            return ds.notRevealedUri;
        }
        string memory currentBaseURI = _baseURI();
        return
            bytes(currentBaseURI).length > 0
                ? string(
                    abi.encodePacked(
                        currentBaseURI,
                        _toString(tokenId),
                        ".json"
                    )
                )
                : "";
    }
    function reveal(bool _state) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.revealed = _state;
    }
    function setMerkleRoots(
        bytes32 _WLRoot,
        bytes32 _OGRoot
    ) external onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.WLmerkleRoot = _WLRoot;
        ds.OGmerkleRoot = _OGRoot;
    }
    function setFreePerWallet(
        uint256 _wllimit,
        uint256 _oglimit
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.wlFree = _wllimit;
        ds.ogFree = _oglimit;
    }
    function setCosts(
        uint256 _publicCost,
        uint256 _WLCost,
        uint256 _ogCost
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.cost = _publicCost;
        ds.wlcost = _WLCost;
        ds.ogcost = _ogCost;
    }
    function setMaxsupply(uint256 _newsupply) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.maxSupply = _newsupply;
    }
    function setBaseURI(string memory _newBaseURI) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.baseURI = _newBaseURI;
    }
    function setNotRevealedURI(string memory _notRevealedURI) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.notRevealedUri = _notRevealedURI;
    }
    function pause(bool _state) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.paused = _state;
    }
    function togglesalePhases(
        bool _public,
        bool _wl,
        bool _og
    ) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.ogSale = _og;
        ds.publicSale = _public;
        ds.preSale = _wl;
    }
    function withdraw() public payable onlyOwner nonReentrant {
        uint256 balance = address(this).balance;
        payable(_msgSenderERC721A()).transfer(balance);
    }
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC721A, ERC2981) returns (bool) {
        return
            ERC721A.supportsInterface(interfaceId) ||
            ERC2981.supportsInterface(interfaceId);
    }
    function setRoyaltyInfo(
        address _receiver,
        uint96 _feeNumerator
    ) external onlyOwner {
        _setDefaultRoyalty(_receiver, _feeNumerator);
    }
    function deleteRoyalty() external onlyOwner {
        _deleteDefaultRoyalty();
    }
    function tokensOfOwner(
        address owner
    ) public view returns (uint256[] memory) {
        unchecked {
            uint256 tokenIdsIdx;
            address currOwnershipAddr;
            uint256 tokenIdsLength = balanceOf(owner);
            uint256[] memory tokenIds = new uint256[](tokenIdsLength);
            TokenOwnership memory ownership;
            for (
                uint256 i = _startTokenId();
                tokenIdsIdx != tokenIdsLength;
                ++i
            ) {
                ownership = _ownershipAt(i);
                if (ownership.burned) {
                    continue;
                }
                if (ownership.addr != address(0)) {
                    currOwnershipAddr = ownership.addr;
                }
                if (currOwnershipAddr == owner) {
                    tokenIds[tokenIdsIdx++] = i;
                }
            }
            return tokenIds;
        }
    }
}
