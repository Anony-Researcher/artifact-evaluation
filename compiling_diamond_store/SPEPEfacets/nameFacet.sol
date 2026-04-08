// SPDX-License-Identifier: UNLICENSE

/*
    MISSED PEPE? DON'T MISS SUPER PEPE!
    https://superpepecoin.vip/
    https://twitter.com/super_pepecoin
    https://t.me/superpepecoineth
    https://www.tiktok.com/@victorreznov101/video/7163066179639201070
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
