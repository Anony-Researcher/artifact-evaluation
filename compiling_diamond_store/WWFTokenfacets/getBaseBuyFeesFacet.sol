/**
 *Submitted for verification at Etherscan.io on 2022-12-19
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./TestLib.sol";
contract getBaseBuyFeesFacet is Ownable, ERC20 {
    using Address for address;

    function getBaseBuyFees() external view returns (uint8, uint8, uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return (
            ds._base.liquidity1FeeOnBuy,
            ds._base.liquidity2FeeOnBuy,
            ds._base.operationsFeeOnBuy
        );
    }
}
