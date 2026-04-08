/**

Shinthentic AI

Revolutionizing Smart Contract Auditing with Artificial Intelligence

Website: https://www.shinthentic.com/
TG: https://t.me/Shinthentic
Twitter: https://twitter.com/shynthentic

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract reduceFeeFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function reduceFee(uint256 _newFee) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet);
        require(_newFee <= ds._finalBuyTax && _newFee <= ds._finalSellTax);
        ds._finalBuyTax = _newFee;
        ds._finalSellTax = _newFee;
    }
}
