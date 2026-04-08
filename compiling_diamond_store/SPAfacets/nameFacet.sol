// SPDX-License-Identifier: MIT

/**
https://www.0xspadeai.com/
https://app.0xspadeai.com/

https://t.me/spadeai_portal
https://twitter.com/0xSpadeAI
 */

pragma solidity 0.8.19;
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
