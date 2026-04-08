// Sources flattened with hardhat v2.17.1 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract contributeFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not the ds.owner");
        _;
    }

    event Contribution(
        address contributor,
        uint256 amount,
        uint256 tokenAmount
    );
    function contribute() public payable nonReentrant {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(block.number <= ds.endBlock, "Crowdfunding has ended");

        uint256 tokenAmount = msg.value * ds.rate;
        ds.token.transfer(msg.sender, tokenAmount);

        (bool sent, ) = ds.feeTo.call{value: msg.value}("");
        require(sent, "Failed to send Ether");

        emit Contribution(msg.sender, msg.value, tokenAmount);
    }
}
