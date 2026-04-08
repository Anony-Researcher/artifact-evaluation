// SPDX-License-Identifier: UNLICENSE

/*
PEPE LORE 

PEPELORE = SHIBARIUM TO SHIBA

https://t.me/pepelore_erc
https://twitter.com/pepelore_eth
http://pepeloreerc.org/
https://knowyourmeme.com/memes/pepe-lore
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
