/**
// SPDX-License-Identifier: MIT
/*
          Telegram: https://t.me/SuperApeERC   
          Twitter: https://twitter.com/SuperApeERC
          Website: https://www.superape.info/   
*/
pragma solidity 0.8.24;
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
