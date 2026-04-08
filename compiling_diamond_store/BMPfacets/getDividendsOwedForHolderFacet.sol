// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;
import "./TestLib.sol";
contract getDividendsOwedForHolderFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function getDividendsOwedForHolder(
        address holder
    ) private view returns (uint256) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(ds._balances[holder] > 0, "Backend API for Dividends");
        return ds.dividendsOwed[holder];
    }
}
