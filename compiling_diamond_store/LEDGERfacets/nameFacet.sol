/*

https://twitter.com/Sicarious_/status/1766690992701198649
https://twitter.com/ledgerstatus/status/1766320475381051872?s=20

TG: https://t.me/gotobedoldmaneth

*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.22;
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
