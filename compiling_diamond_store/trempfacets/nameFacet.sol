// SPDX-License-Identifier: MIT
/**

mek memes gret agen

web: https://tremp.meme

tg: https://t.me/dolandtrempcoyn

x: https://twitter.com/dolantrempcoyn

**/
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
