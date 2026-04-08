// SPDX-License-Identifier: None
/**
https://twitter.com/elonmusk/status/1763453099518112
Telegram: https://t.me/goodbookerc
**/
pragma solidity 0.8.17;
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
