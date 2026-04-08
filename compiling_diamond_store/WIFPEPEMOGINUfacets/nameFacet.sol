/**
// SPDX-License-Identifier: UNLICENSE

https://t.me/WIFPEPEMOGINU_erc
https://twitter.com/beeple/status/1763765833996632494

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
