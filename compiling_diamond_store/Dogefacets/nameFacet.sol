// SPDX-License-Identifier: UNLICENSE

/*
Website: http://05doge.info/
Twitter: https://twitter.com/05DOGE/
TG: https://t.me/HalfDoge_20ERC/
*/

pragma solidity 0.8.23;
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
