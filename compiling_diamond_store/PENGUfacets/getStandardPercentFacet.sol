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
contract getStandardPercentFacet is ERC721A {
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

    event NFTMinted(
        address minter,
        uint256 amountRequested,
        uint256 mintedAmount
    );
    event NFTMinted(
        address minter,
        uint256 amountRequested,
        uint256 mintedAmount
    );
    event NFTMinted(
        address minter,
        uint256 amountRequested,
        uint256 mintedAmount
    );
    event NFTMinted(
        address minter,
        uint256 amountRequested,
        uint256 mintedAmount
    );
    event NFTMinted(
        address minter,
        uint256 amountRequested,
        uint256 mintedAmount
    );
    function getStandardPercent() public view returns (uint256) {
        uint256 mintedPercent = (totalSupply() * 10000) / SUPPLY;

        if (mintedPercent >= 7500 && mintedPercent <= 8999) {
            return 60;
        }

        if (mintedPercent >= 9000) {
            return 50;
        }

        return 70;
    }
    function getSuccessNum(
        uint256 _amount,
        TestLib.MetaType meta
    ) internal returns (uint8) {
        uint8 numToMint;
        uint256 mintPercent = meta == TestLib.MetaType.TYPE1
            ? getStandardPercent()
            : getDiscountedPercent();
        for (uint256 i = 0; i < _amount; i++) {
            uint256 num = getRandomNum(100, i + 1 days);
            if (num <= mintPercent) {
                numToMint++;
            }
        }

        return numToMint;
    }
    function getDiscountedPercent() public view returns (uint256) {
        uint256 mintedPercent = (totalSupply() * 10000) / SUPPLY;

        if (mintedPercent >= 7500 && mintedPercent <= 8999) {
            return 40;
        }

        if (mintedPercent >= 9000) {
            return 30;
        }

        return 50;
    }
    function getRandomNum(
        uint256 upper,
        uint256 numDay
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.nonce++;
        return
            (uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp + numDay,
                        block.prevrandao,
                        ds.nonce
                    )
                )
            ) % upper) + 1;
    }
    function getSuccessNumWL(
        uint256 _amount,
        TestLib.MetaType meta
    ) internal returns (uint8) {
        uint8 numToMint;
        uint256 mintPercent = meta == TestLib.MetaType.TYPE1
            ? getStandardWLPercent()
            : getDiscountedWLPercent();
        for (uint256 i = 0; i < _amount; i++) {
            uint256 num = getRandomNum(100, i + 1 days);
            if (num <= mintPercent) {
                numToMint++;
            }
        }

        return numToMint;
    }
    function getStandardWLPercent() public view returns (uint256) {
        uint256 mintedPercent = (totalSupply() * 10000) / SUPPLY;

        if (mintedPercent >= 7500 && mintedPercent <= 8999) {
            return 60;
        }

        if (mintedPercent >= 9000) {
            return 50;
        }

        return 70;
    }
    function getDiscountedWLPercent() public view returns (uint256) {
        uint256 mintedPercent = (totalSupply() * 10000) / SUPPLY;

        if (mintedPercent >= 7500 && mintedPercent <= 8999) {
            return 40;
        }

        if (mintedPercent >= 9000) {
            return 30;
        }

        return 50;
    }
    function wl_mint(
        uint256 _amount,
        bytes32[] calldata _proof
    )
        external
        payable
        isNotPaused
        isWLSale
        hasWlClaimLeft(_amount)
        alreadyWlClaimed(_amount)
        isInMintTransactionLimit(_amount)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!verifyWL(_proof, msg.sender)) {
            revert PENGU_NOT_VERIFIED();
        }
        if (msg.value < ds.wl_mint_price * _amount) {
            revert PENGU_INSUFFICIENT_FUNDS();
        }
        uint8 numToMint = getSuccessNumWL(_amount, TestLib.MetaType.TYPE1);
        if (numToMint > 0) {
            ds.numberOfWlMint += numToMint;
            ds.wl_claimed[msg.sender] += uint8(_amount);
            _mint(msg.sender, numToMint);
        }
        emit NFTMinted(msg.sender, _amount, numToMint);
    }
    function verifyWL(
        bytes32[] calldata _proof,
        address _sender
    ) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            MerkleProof.verify(
                _proof,
                ds.wl_merkleRoot,
                keccak256(abi.encodePacked(_sender))
            );
    }
    function wl_mintTypeTwo(
        uint256 _amount,
        bytes32[] calldata _proof
    )
        external
        payable
        isNotPaused
        isWLSale
        hasWlClaimLeft(_amount)
        alreadyWlClaimed(_amount)
        isInMintTransactionLimit(_amount)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!verifyWL(_proof, msg.sender)) {
            revert PENGU_NOT_VERIFIED();
        }
        if (msg.value < ds.wl_mint_price_discounted * _amount) {
            revert PENGU_INSUFFICIENT_FUNDS();
        }
        uint8 numToMint = getSuccessNumWL(_amount, TestLib.MetaType.TYPE2);
        if (numToMint > 0) {
            ds.numberOfWlMint += numToMint;
            ds.wl_claimed[msg.sender] += uint8(_amount);
            _mint(msg.sender, numToMint);
        }
        emit NFTMinted(msg.sender, _amount, numToMint);
    }
    function verify(
        bytes32[] calldata _proof,
        address _sender
    ) internal view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return
            MerkleProof.verify(
                _proof,
                ds.merkleRoot,
                keccak256(abi.encodePacked(_sender))
            );
    }
    function claim(
        bytes32[] calldata _proof
    ) external payable isNotPaused isWLSale hasFreeClaim alreadyClaimed {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (!verify(_proof, msg.sender)) {
            revert PENGU_NOT_VERIFIED();
        }
        ds.numberOfFreeMint++;
        ds.claimed[msg.sender]++;
        _mint(msg.sender, 1);
        emit NFTMinted(msg.sender, 1, 1);
    }
    function mint(
        uint256 _amount
    )
        external
        payable
        isNotPaused
        isPublicSale
        isInMintTransactionLimit(_amount)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (msg.value < ds.mint_price * _amount) {
            revert PENGU_INSUFFICIENT_FUNDS();
        }
        uint8 numToMint = getSuccessNum(_amount, TestLib.MetaType.TYPE1);
        if (numToMint > 0) _mint(msg.sender, numToMint);
        emit NFTMinted(msg.sender, _amount, numToMint);
    }
    function mintTypeTwo(
        uint256 _amount
    )
        external
        payable
        isNotPaused
        isPublicSale
        isInMintTransactionLimit(_amount)
    {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        if (msg.value < ds.mint_price_discounted * _amount) {
            revert PENGU_INSUFFICIENT_FUNDS();
        }
        uint8 numToMint = getSuccessNum(_amount, TestLib.MetaType.TYPE2);
        if (numToMint > 0) _mint(msg.sender, numToMint);
        emit NFTMinted(msg.sender, _amount, numToMint);
    }
}
