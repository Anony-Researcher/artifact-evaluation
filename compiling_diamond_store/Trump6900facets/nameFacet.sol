// SPDX-License-Identifier: MIT

/*
Website: https://trump6900coin.com

Twitter: twitter.com/TAGAMemecoin

Telegram: https://t.me/TAGAPortal

Linktree: https://linktr.ee/TAGA6900

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
