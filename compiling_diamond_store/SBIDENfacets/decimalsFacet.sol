/**
// SPDX-License-Identifier: UNLICENSE

------------Super Biden------------


t.me/superbideneth

superbiden.xyz

twitter.com/superbideneth

Because Joe just rememberd he got super powers 


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
