// File: contracts/External/IERC721Receiver.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.4;
import "./TestLib.sol";
contract verifySignFacet is ERC721 {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.owner == msg.sender, "Ownable: caller is not the ds.owner");
        _;
    }

    function verifySign(
        string memory tokenURI,
        address caller,
        TestLib.Sign memory sign
    ) internal view {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        bytes32 hash = keccak256(
            abi.encodePacked(this, caller, tokenURI, sign.nonce)
        );
        require(
            ds.owner ==
                ecrecover(
                    keccak256(
                        abi.encodePacked(
                            "\x19Ethereum Signed Message:\n32",
                            hash
                        )
                    ),
                    sign.v,
                    sign.r,
                    sign.s
                ),
            "Owner sign verification failed"
        );
    }
    function createNFT(
        string memory tokenURI,
        uint256 fee
    ) external returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        //  require(!ds.usedNonce[sign.nonce], "Nonce : Invalid Nonce");
        //require(!ds.tokenURIs[tokenURI],"Minting: Duplicate Minting");
        //  ds.usedNonce[sign.nonce] = true;
        uint256 newItemId = ds.tokenCounter;
        //  verifySign(tokenURI, msg.sender, sign);
        _safeMint(msg.sender, newItemId, fee);
        _setTokenURI(newItemId, tokenURI);
        ds.tokenURIs[tokenURI] = true;
        ds.tokenCounter = ds.tokenCounter + 1;
        return newItemId;
    }
}
