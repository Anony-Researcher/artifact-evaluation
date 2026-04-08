// File: contracts/External/IERC721Receiver.sol

// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC721/IERC721Receiver.sol)

pragma solidity ^0.8.4;
import "./TestLib.sol";
contract transferOwnershipFacet is ERC721 {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds.owner == msg.sender, "Ownable: caller is not the ds.owner");
        _;
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    function transferOwnership(
        address newOwner
    ) external onlyOwner returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newOwner != address(0),
            "Ownable: new ds.owner is the zero address"
        );
        ds.owner = newOwner;
        emit OwnershipTransferred(ds.owner, newOwner);
        return true;
    }
}
