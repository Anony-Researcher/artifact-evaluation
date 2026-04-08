// SPDX-License-Identifier: MIT

/**
Website:     https://www.optimus.loans
DApp:        https://app.optimus.loans
Document:    https://docs.optimus.loans

Telegram:    https://t.me/optimusloans
Twitter:     https://x.com/optimusloans
**/

pragma solidity 0.8.11;
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
