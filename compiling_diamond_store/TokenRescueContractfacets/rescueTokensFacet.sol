// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract rescueTokensFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.owner,
            "This function is restricted to the contract's ds.owner."
        );
        _;
    }

    function rescueTokens(
        address tokenAddress,
        address to,
        uint256 amount
    ) external onlyOwner {
        require(
            IERC20(tokenAddress).transfer(to, amount),
            "Token transfer failed."
        );
    }
}
