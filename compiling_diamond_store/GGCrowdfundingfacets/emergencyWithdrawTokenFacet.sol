// Sources flattened with hardhat v2.17.1 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract emergencyWithdrawTokenFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not the ds.owner");
        _;
    }

    event EmergencyWithdrawal(address indexed to, uint256 tokenBalance);
    function emergencyWithdrawToken() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 tokenBalance = ds.token.balanceOf(address(this));
        require(tokenBalance > 0, "No tokens to withdraw");

        bool sent = ds.token.transfer(ds.owner, tokenBalance);
        require(sent, "Token transfer failed");

        emit EmergencyWithdrawal(ds.owner, tokenBalance);
    }
}
