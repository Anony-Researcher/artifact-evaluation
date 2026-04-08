// SPDX-License-Identifier: MIT

/*
    ** Pixeria AI is a AI based cross-chain money market for earning passive yield and accessing instant backed loans. **

    Web      : https://pixeria.loan
    Docs     : https://docs.pixeria.loan

    Twitter  : https://x.com/Pixeria_AI_Loan
    Telegram : https://t.me/pixeria_loan_official
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
