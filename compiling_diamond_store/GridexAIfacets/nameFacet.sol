// SPDX-License-Identifier: MIT

/*    
    Website : https://www.gridexai.com
    Docs    : https://docs.gridexai.com

    Telegram : https://t.me/gridexai_portal
    Twitter  : https://twitter.com/Gridex_AI
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
