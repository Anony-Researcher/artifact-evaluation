// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract addTokenFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.owner,
            "Only the ds.owner can call this function"
        );
        _;
    }

    function addToken(address tokenAddress) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._allTokens.push(tokenAddress);
    }
}
