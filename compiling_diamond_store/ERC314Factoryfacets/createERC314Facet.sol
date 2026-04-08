// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import "./TestLib.sol";
contract createERC314Facet {
    event TokenCreated(address tokenAddress);
    function createERC314(
        string memory name,
        string memory symbol,
        uint256 totalSupply,
        uint256 fee,
        uint256 deployerSupplyPercentage
    ) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(deployerSupplyPercentage <= 100, "percent cannot exceed 100%");
        EVToken newToken = new EVToken(
            name,
            symbol,
            totalSupply,
            fee,
            deployerSupplyPercentage,
            ds.owner
        );
        ds.allTokens.push(address(newToken));
        emit TokenCreated(address(newToken));
    }
}
