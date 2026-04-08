// SPDX-License-Identifier: UNLICENSE

/*

EL SAPO PEPE $ELSAPO 

The basis and inspiration for the creation of $PEPE

https://t.me/elsapopepeerc

https://twitter.com/elsapopepeerc

http://elsapopepe.io/

*/

pragma solidity 0.8.23;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
