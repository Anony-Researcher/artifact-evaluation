/**

    Website: https://charliecoineth.com/
    
    X: https://twitter.com/charliecoineth

    TG: https://t.me/charlieYEAH

*/
// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;
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
