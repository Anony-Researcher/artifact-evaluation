/**
https://t.me/MaximumPlanck
https://x.com/elonmusk/status/1772027984930611241?s=52&t=Fy14sqDz2upGEF0vQnjj0w

// SPDX-License-Identifier: UNLICENSE



*/
pragma solidity 0.8.23;
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
