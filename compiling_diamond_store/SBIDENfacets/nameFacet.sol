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
