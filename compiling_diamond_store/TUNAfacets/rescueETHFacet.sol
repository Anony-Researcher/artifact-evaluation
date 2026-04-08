/**

    https://twitter.com/tunacoineth

**/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "./TestLib.sol";
contract rescueETHFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function rescueETH() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._operationsWallet);
        bool success;
        (success, ) = address(ds._operationsWallet).call{
            value: address(this).balance
        }("");
    }
}
