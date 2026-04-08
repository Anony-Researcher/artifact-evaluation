// SPDX-License-Identifier: UNLICENSE

/*
Telegram: https://t.me/Pepega_ERC20

Twitch: https://www.twitch.tv/pepegaerc

Website: https://pepegaerc.vip/

**/
pragma solidity 0.8.23;
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
