// SPDX-License-Identifier: MIT
/*


THE "WIDE TRUMP" MEME IS A HUMOROUS TRENDING INTERNET SENSATION THAT EMERGED DURING DONALD TRUMP'S PRESIDENCY. THIS MEME INVOLVES DIGITALLY MANIPULATING IMAGES OF TRUMP TO GIVE THE IMPRESSION THAT HIS ENTIRE BODY HAS BEEN WIDENED, THEY EVEN CALL HIM "THE WALL"

https://t.me/widetrumpeth
https://twitter.com/WideTrumpETH
https://widetrumpeth.com/


*/
pragma solidity 0.8.20;
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
