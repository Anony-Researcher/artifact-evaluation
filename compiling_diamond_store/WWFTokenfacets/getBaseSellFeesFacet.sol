/**
 *Submitted for verification at Etherscan.io on 2022-12-19
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./TestLib.sol";
contract getBaseSellFeesFacet is Ownable, ERC20 {
    using Address for address;

    function getBaseSellFees() external view returns (uint8, uint8, uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (
            ds._base.liquidity1FeeOnSell,
            ds._base.liquidity2FeeOnSell,
            ds._base.operationsFeeOnSell
        );
    }
}
