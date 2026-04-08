/**

    Website: https://meruai.net/
    Docs: https://docs.meruai.net/
    Twitter: https://twitter.com/meru_ai_app
    Telegram: https://t.me/meru_ai_app

**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.25;
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
