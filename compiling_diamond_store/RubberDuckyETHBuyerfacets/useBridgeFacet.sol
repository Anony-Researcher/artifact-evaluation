//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./TestLib.sol";
contract useBridgeFacet is Ownable, AxelarExecutable {
    function useBridge(
        address to,
        uint256 gas,
        uint256 minOutUSDC,
        uint256 minOut,
        uint112 percentForGas
    ) external payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(gas >= ds.minGas, "Min Gas Error");
        require(msg.value > gas, "Too Much Gas");
        require(to != address(0), "Zero To");
        _useBridge(to, gas, minOutUSDC, minOut, percentForGas);
    }
    function _useBridge(
        address to,
        uint256 gas,
        uint256 minOutUSDC,
        uint256 minOut,
        uint112 percentForGas
    ) internal {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // amount to swap is value - gas
        uint256 preTaxAmount = msg.value - gas;

        // calculate fee
        uint256 feeAmount = (preTaxAmount * ds.defaultFee) / FEE_DENOM;

        // amount to swap is preTaxAmount - fee
        uint256 amount = preTaxAmount - feeAmount;
        require(amount > 0, "Zero Amount");

        // send fee to destination
        if (feeAmount > 0) {
            TransferHelper.safeTransferETH(ds.feeReceiver, feeAmount);
        }

        // make swaps to get native into ds.USDC
        uint256 usdcAmount = _swap(amount, minOutUSDC);

        // create payload using the amount received to cover tax-on-transfer tokens
        bytes memory payload = abi.encode(to, percentForGas, minOut);

        // pass payload into ds.gasService, paying the gas for the next call
        ds.gasService.payNativeGasForContractCallWithToken{value: gas}(
            address(this),
            ds.destinationChain,
            ds.destinationAddress,
            payload,
            "ds.USDC",
            usdcAmount,
            msg.sender
        );

        // approve of ds.USDC to the gateway
        TransferHelper.safeApprove(ds.USDC, address(gateway), usdcAmount);

        // Call Contract On The Gateway
        gateway.callContractWithToken(
            ds.destinationChain,
            ds.destinationAddress,
            payload,
            "ds.USDC",
            usdcAmount
        );
    }
    function _swap(
        uint256 amount,
        uint256 minOutUSDC
    ) internal returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        // swapping ETH to ds.USDC
        ds.V2Router.swapExactETHForTokens{value: amount}(
            minOutUSDC,
            ds.path,
            address(this),
            block.timestamp + 1000
        );

        // return balance of ds.USDC received
        return IERC20(ds.USDC).balanceOf(address(this));
    }
}
