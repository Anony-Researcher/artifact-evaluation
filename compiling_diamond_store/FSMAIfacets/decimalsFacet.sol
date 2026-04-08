// SPDX-License-Identifier: Unlicensed

/*
Encountered a scammer attempting to exploit you? Capture their wallet address and promptly report it to us! Earn rewards for your vigilant actions!

Web: https://fuckscam.pro
Tg: https://t.me/fuckscam_official
X: https://x.com/FuckScam_X
Medium: https://medium.com/@fuckscam
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._securedLoop = true;
        _;
        ds._securedLoop = false;
    }

    function decimals() public view returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.decimals_;
    }
}
