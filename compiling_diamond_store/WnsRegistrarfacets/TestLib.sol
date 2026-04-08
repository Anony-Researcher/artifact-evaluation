// File: wns-multichain/implementations/wns_addresses_impl.sol

pragma solidity 0.8.24;

interface WnsAddressesInterface {
    function owner() external view returns (address);
    function getWnsAddress(
        string memory _label
    ) external view returns (address);
}

abstract contract WnsImpl {
    WnsAddressesInterface wnsAddresses;

    constructor(address addresses_) {
        wnsAddresses = WnsAddressesInterface(addresses_);
    }

    function setAddresses(address addresses_) public {
        require(msg.sender == owner(), "Not authorized.");
        wnsAddresses = WnsAddressesInterface(addresses_);
    }

    function owner() public view returns (address) {
        return wnsAddresses.owner();
    }

    function getWnsAddress(string memory _label) public view returns (address) {
        return wnsAddresses.getWnsAddress(_label);
    }

    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    modifier onlyTeam() {
        require(
            msg.sender == getWnsAddress("team"),
            "Ownable: caller is not team"
        );
        _;
    }
}
// File: wns-multichain/wns_registrar.sol

pragma solidity 0.8.24;

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        _status = _NOT_ENTERED;
    }

    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == _ENTERED;
    }
}

interface WnsRegistryInterface {
    function owner() external view returns (address);
    function getWnsAddress(
        string memory _label
    ) external view returns (address);
    function setRecord(
        bytes32 _hash,
        uint256 _tokenId,
        string memory _name,
        uint8 _tier
    ) external;
    function setRecord(uint256 _tokenId, string memory _name) external;
    function getRecord(bytes32 _hash) external view returns (uint256);
    function upgradeTier(uint256 _tokenId, uint8 _tier) external;
}

interface WnsErc721Interface {
    function mintErc721(address to) external;
    function getNextTokenId() external view returns (uint256);
    function ownerOf(uint256 tokenId) external view returns (address);
}

contract Computation {
    function computeNamehash(
        string memory _name
    ) public pure returns (bytes32 namehash) {
        namehash = 0x0000000000000000000000000000000000000000000000000000000000000000;
        namehash = keccak256(
            abi.encodePacked(namehash, keccak256(abi.encodePacked("eth")))
        );
        namehash = keccak256(
            abi.encodePacked(namehash, keccak256(abi.encodePacked(_name)))
        );
    }
}

abstract contract Signatures {
    struct Register {
        string name;
        string extension;
        uint8 tier;
        address registrant;
        uint256 chainId;
        uint256 cost;
        uint256 expiration;
        address[] splitAddresses;
        uint256[] splitAmounts;
    }

    struct TierUpgrade {
        uint256 tokenId;
        uint8 tier;
        uint256 cost;
        uint256 expiration;
    }

    function verifySignature(
        Register memory _register,
        bytes memory sig
    ) internal pure returns (address) {
        bytes32 message = keccak256(
            abi.encode(
                _register.name,
                _register.extension,
                _register.tier,
                _register.registrant,
                _register.chainId,
                _register.cost,
                _register.expiration,
                _register.splitAddresses,
                _register.splitAmounts
            )
        );
        return recoverSigner(message, sig);
    }

    function verifyTierUpgradeSignature(
        TierUpgrade memory _tierUpgrade,
        bytes memory sig
    ) internal pure returns (address) {
        bytes32 message = keccak256(
            abi.encode(
                _tierUpgrade.tokenId,
                _tierUpgrade.tier,
                _tierUpgrade.cost,
                _tierUpgrade.expiration
            )
        );
        return recoverSigner(message, sig);
    }

    function recoverSigner(
        bytes32 message,
        bytes memory sig
    ) public pure returns (address) {
        uint8 v;
        bytes32 r;
        bytes32 s;
        (v, r, s) = splitSignature(sig);
        return ecrecover(message, v, r, s);
    }

    function splitSignature(
        bytes memory sig
    ) internal pure returns (uint8, bytes32, bytes32) {
        require(sig.length == 65);

        bytes32 r;
        bytes32 s;
        uint8 v;

        assembly {
            r := mload(add(sig, 32))
            s := mload(add(sig, 64))
            v := byte(0, mload(add(sig, 96)))
        }

        return (v, r, s);
    }
}

library TestLib {
    bytes32 constant DIAMOND_STORAGE_POSITION =
        keccak256("diamond.standard.Test.storage");

    struct TestStorage {
        bool isActive;
        uint256 minLength;
        uint256 maxLength;
        uint256 chainId;
    }

    function diamondStorage() internal pure returns (TestStorage storage ds) {
        bytes32 position = DIAMOND_STORAGE_POSITION;
        assembly {
            ds.slot := position
        }
    }
}
