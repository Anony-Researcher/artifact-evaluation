// SPDX-License-Identifier: Unlicensed

/*
Protocol to Redefining SocialFi to Empower All.

Website: https://soulcial.pro
Telegram: https://t.me/soulcial_portal
Twitter: https://twitter.com/soulcial_fi
Dapp: https://app.soulcial.pro

*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isInSecure = true;
        _;
        ds._isInSecure = false;
    }

    function decimals() public view returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.decimals_;
    }
}
