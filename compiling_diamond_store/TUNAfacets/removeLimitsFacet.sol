/**

    https://twitter.com/tunacoineth

**/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.23;
import "./TestLib.sol";
contract removeLimitsFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    event MaxTxAmountUpdated(uint _maxTxAmount);
    function removeLimits() external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._operationsWallet);
        ds._maxTxAmount = _tTotal;
        ds._maxWalletSize = _tTotal;
        emit MaxTxAmountUpdated(_tTotal);
    }
}
