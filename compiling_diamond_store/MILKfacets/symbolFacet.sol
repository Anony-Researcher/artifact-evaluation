//SPDX-License-Identifier: MIT

/**

https://x.com/milksweeney/status/1764061837488755009?s=46
https://t.me/milksweeney
http://www.milksweeney.com/

(.)(.) the boobs are the tech (.)(.)

**/

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
