//SPDX-License-Identifier: MIT

//Telegram: https://t.me/eclipsecoin
// Twitter: https://twitter.com/eclipse
// Website: https://eclipse2024coin.io
// Discord: https://discord.com/invite/Va58aMrcwk

pragma solidity ^0.5.8;
import "./TestLib.sol";
contract decimalsFacet {
    function decimals() public view returns (uint8) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.tokenDecimals;
    }
}
