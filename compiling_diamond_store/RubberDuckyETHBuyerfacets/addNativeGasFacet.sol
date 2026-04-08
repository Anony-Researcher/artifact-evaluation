//SPDX-License-Identifier: MIT
pragma solidity 0.8.20;
import "./TestLib.sol";
contract addNativeGasFacet is Ownable, AxelarExecutable {
    function addNativeGas(
        bytes32 txHash,
        uint256 logIndex,
        address refundAddress
    ) external payable {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.gasService.addNativeGas{value: msg.value}(
            txHash,
            logIndex,
            refundAddress
        );
    }
}
