// SPDX-License-Identifier: UNLICENSE

/*

30 Days of Content in 5 minutes

Website: https://mymarky.ai/
Twitter: https://twitter.com/MyMarkyETH

*/

pragma solidity 0.8.23;
import "./TestLib.sol";
contract symbolFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function symbol() public pure returns (string memory) {
        return _symbol;
    }
}
