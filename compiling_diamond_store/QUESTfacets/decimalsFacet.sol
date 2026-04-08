/**

   ▄████████     ███        ▄█    █▄       ▄████████    ▄████████ ████████▄   ███    █▄     ▄████████    ▄████████     ███     
  ███    ███ ▀█████████▄   ███    ███     ███    ███   ███    ███ ███    ███  ███    ███   ███    ███   ███    ███ ▀█████████▄ 
  ███    █▀     ▀███▀▀██   ███    ███     ███    █▀    ███    ███ ███    ███  ███    ███   ███    █▀    ███    █▀     ▀███▀▀██ 
  ███▄▄▄         ███   ▀  ▄███▄▄▄▄███▄▄  ▄███▄▄▄      ▄███▄▄▄▄██▀ ███    ███  ███    ███  ▄███▄▄▄       ███            ███   ▀ 
  ███▀▀▀         ███     ▀▀███▀▀▀▀███▀  ▀▀███▀▀▀     ▀▀███▀▀▀▀▀   ███    ███  ███    ███ ▀▀███▀▀▀     ▀███████████     ███     
  ███    █▄      ███       ███    ███     ███    █▄  ▀███████████ ███    ███  ███    ███   ███    █▄           ███     ███     
  ███    ███     ███       ███    ███     ███    ███   ███    ███ ███    ███  ███    ███   ███    ███    ▄█    ███     ███     
  ██████████    ▄████▀     ███    █▀      ██████████   ███    ███  ▀██████▀▄█ ████████▀    ██████████  ▄████████▀     ▄████▀ 

EtherQuest: A mobile odyssey of discovery where you capture, train, and battle Ethermons.

Capture and collect a variety of Ethermon, each one a 3D masterpiece. Train them, level them up, and engage in epic, tactical PvP battles. 
As you strategize and build your ultimate Ethermon army, make your way into the battle arenas and compete for $QUEST prizepools.

Website: https://ether.quest/
X: https://twitter.com/ether_quest
Telegram Community: https://t.me/Ether_Quest
Discord: https://discord.com/invite/etherquest
YouTube: https://www.youtube.com/@Ether-Quest
Blog: https://blog.ether.quest/
Linktree: http://linktr.ee/EtherQuest
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
