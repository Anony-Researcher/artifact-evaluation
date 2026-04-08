/**
The world's savings protocol, run by you.
Dove Pool is a prize savings protocol, enabling you to win by saving.

1. Deposit USDC for a chance to win
2. Participate in daily prize draws
3. Withdraw your deposit any time - even if you don't win!

Website:            https://www.dovepool.org
Pool:               https://pool.dovepool.org
Document:           https://docs.dovepool.org
Twitter:            https://twitter.com/dove_pool
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.19;
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
