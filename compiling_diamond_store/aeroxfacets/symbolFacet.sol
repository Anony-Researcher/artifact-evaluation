// SPDX-License-Identifier: MIT

/** 
Introducing AeroX an innovative project with a suite of Multi Chain Trading utilities. 

TG: https://t.me/aerox_portal
Web: https://aeroxerc.com/
X: https://twitter.com/aeroxerc
Docs: https://aerox.gitbook.io/aerox-whitepaper/
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
