/**
 *Submitted for verification at Etherscan.io on 2023-05-10
 */
//https://twitter.com/jimcramer/status/1765106596584026265
//https://t.me/Pipcramererc20
// SPDX-License-Identifier: NONE

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
