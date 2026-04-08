// SPDX-License-Identifier: MIT

/*    
    Website :  https://www.igridai.com
    DApp    :  https://app.igridai.com
    Docs    :  https://docs.igridai.com

    Telegram :  https://t.me/IgridAI
    Twitter  :  https://twitter.com/IgridAI
*/

pragma solidity 0.8.19;
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
