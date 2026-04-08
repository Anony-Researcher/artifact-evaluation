// SPDX-License-Identifier: MIT

/*
    Web : https://dramaai.org
    App : https://app.dramaai.org
    Doc : https://docs.dramaai.org

    Twitter  : https://twitter.com/dramaaitech
    Telegram : https://t.me/dramaai_official
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
