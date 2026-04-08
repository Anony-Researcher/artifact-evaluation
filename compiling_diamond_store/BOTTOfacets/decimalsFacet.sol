// SPDX-License-Identifier: Unlicensed

/*
BottoAI creates works of art based on collective feedback from the community. Our participation is what completes BottoAI as an artist.

Website: https://www.bottoai.art
Telegram: https://t.me/BottoAI_erc
Twitter: https://twitter.com/BottoAI_erc
*/

pragma solidity 0.8.19;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._isGuarded = true;
        _;
        ds._isGuarded = false;
    }

    function decimals() public view returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.decimals_;
    }
}
