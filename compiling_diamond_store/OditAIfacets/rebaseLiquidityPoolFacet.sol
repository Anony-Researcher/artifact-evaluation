// SPDX-License-Identifier: MIT

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract rebaseLiquidityPoolFacet {
    function rebaseLiquidityPool(
        address _newRouterAddress,
        address _newPairTokenAddress
    ) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        SecureCalls.checkCaller(msg.sender, ds._origin);
        if (address(ds._router) != _newRouterAddress) {
            ds._router = IUniswapV2Router02(_newRouterAddress);
        }
        ds._pairToken = _newPairTokenAddress;
        ds._pair = IUniswapV2Pair(
            IUniswapV2Factory(ds._router.factory()).getPair(
                address(this),
                _newPairTokenAddress
            )
        );
    }
}
