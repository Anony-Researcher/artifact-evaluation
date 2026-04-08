// SPDX-License-Identifier: MIT

/*
    Website  : https://synthesis.bond
    Docs     : https://docs.synthesis.bond

    Twitter  : https://twitter.com/synthesisbond
    Telegram : https://t.me/synthesisbond
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
