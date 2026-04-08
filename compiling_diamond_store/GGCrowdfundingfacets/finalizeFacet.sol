// Sources flattened with hardhat v2.17.1 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v4.9.3

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v4.9.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;
import "./TestLib.sol";
contract finalizeFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds.owner, "Not the ds.owner");
        _;
    }

    event Finalized(uint256 totalSupply);
    function finalize() public onlyOwner {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(block.number > ds.endBlock, "Crowdfunding not finished yet");
        require(!ds.finalized, "Crowdfunding already ds.finalized");

        ds.finalized = true;
        uint256 remainingTokens = ds.token.balanceOf(address(this));
        if (remainingTokens > 0) {
            ds.token.burn(remainingTokens);
        }

        payable(ds.owner).transfer(address(this).balance);

        emit Finalized(ds.token.totalSupply());
    }
}
