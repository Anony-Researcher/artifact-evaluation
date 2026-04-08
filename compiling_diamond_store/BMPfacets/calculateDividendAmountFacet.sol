// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "./TestLib.sol";
contract calculateDividendAmountFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function calculateDividendAmount(
        address holder,
        uint256 amount
    ) private view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        uint256 balance = ds.tokenBalance[holder];
        uint256 magnifier = getMagnifier(balance);
        uint256 dividendAmount = SafeMath.mul(amount, balance);
        dividendAmount = SafeMath.div(
            dividendAmount,
            15_000_000 * 10 ** _decimals
        );
        dividendAmount = SafeMath.mul(dividendAmount, magnifier);
        dividendAmount = SafeMath.div(dividendAmount, 100);
        return dividendAmount;
    }
    function getMagnifier(uint256 balance) private pure returns (uint256) {
        uint256 magnifier = 100; // Base magnifier
        if (balance >= 105000 * 10 ** 8) {
            // 0.7% of total supply
            magnifier = 135;
        } else if (balance >= 75000 * 10 ** 8) {
            // 0.5% of total supply
            magnifier = 125;
        } else if (balance >= 45000 * 10 ** 8) {
            // 0.3% of total supply
            magnifier = 115;
        }
        return magnifier;
    }
}
