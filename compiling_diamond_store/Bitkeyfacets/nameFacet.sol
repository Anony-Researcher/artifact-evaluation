// SPDX-License-Identifier: UNLICENSE

/*
    https://twitter.com/DocumentingBTC/status/1764343426655387690
    https://t.me/Bitkeycoinerc20
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
