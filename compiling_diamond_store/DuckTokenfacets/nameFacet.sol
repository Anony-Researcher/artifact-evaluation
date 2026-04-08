/**
//SPDX-License-Identifier: MIT

/**
Telegram: https://t.me/ducketh_portal
Website: www.duck.fun
X: https://x.com/ducketh_
Discord: https://discord.gg/YTZtZSFtmy
*/
pragma solidity ^0.8.18;
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
