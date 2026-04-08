/**
TectraAI is a AI based cross-chain money market for earning passive yield and accessing instant backed loans.

Web: https://tectra.loan
X: https://x.com/TectraAI_Loan
Tg: https://t.me/tectra_loan_official
M: https://medium.com/@tectra.loan
**/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
