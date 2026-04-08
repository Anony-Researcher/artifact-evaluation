/**
// SPDX-License-Identifier: UNLICENSE

------------Wide Putin Meme------------

Vladimir putin is reelected as the "widest" president of russia 2024

https://t.me/wideputinETH

https://wideputineth.com/

https://twitter.com/wideputinETH

---------------------------------------
Powered by https://t.me/FairLaunchDev
---------------------------------------
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
