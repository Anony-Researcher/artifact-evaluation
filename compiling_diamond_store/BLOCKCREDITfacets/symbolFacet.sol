/**

Block Credit - $BLC

https://www.blockcredit.cash
https://stake.blockcredit.cash
https://docs.blockcredit.cash

https://t.me/blockcreditcash
https://twitter.com/blockcreditcash

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
