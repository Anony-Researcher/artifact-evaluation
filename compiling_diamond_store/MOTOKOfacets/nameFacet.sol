/*

https://twitter.com/ksicrypto/status/1776623337239695444?s=46&t=x75MRGOBELME4Uo_2ZTBvg

 TG: https://t.me/MOTOKOETH


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
