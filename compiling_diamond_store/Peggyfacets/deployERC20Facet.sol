// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./TestLib.sol";
contract deployERC20Facet {
    using SafeERC20 for IERC20;

    function deployERC20(
        string calldata _cosmosDenom,
        string calldata _name,
        string calldata _symbol,
        uint8 _decimals
    ) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // Deploy an ERC20 with entire supply granted to Peggy.sol
        CosmosERC20 erc20 = new CosmosERC20(
            address(this),
            _name,
            _symbol,
            _decimals
        );

        // Fire an event to let the Cosmos module know
        ds.state_lastEventNonce = ds.state_lastEventNonce + 1;
        emit ERC20DeployedEvent(
            _cosmosDenom,
            address(erc20),
            _name,
            _symbol,
            _decimals,
            ds.state_lastEventNonce
        );
    }
}
