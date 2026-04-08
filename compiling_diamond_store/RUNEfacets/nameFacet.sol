/*

██████  ██    ██ ███    ██ ███████ ██████   ██████  ██    ██ ███    ██ ██████  
██   ██ ██    ██ ████   ██ ██      ██   ██ ██    ██ ██    ██ ████   ██ ██   ██ 
██████  ██    ██ ██ ██  ██ █████   ██████  ██    ██ ██    ██ ██ ██  ██ ██   ██ 
██   ██ ██    ██ ██  ██ ██ ██      ██   ██ ██    ██ ██    ██ ██  ██ ██ ██   ██ 
██   ██  ██████  ██   ████ ███████ ██████   ██████   ██████  ██   ████ ██████  
                                                                               
ᴇxᴘʟᴏʀᴇ ᴇʟʏʀɪᴀ, ᴀ ᴡᴏʀʟᴅ ꜰᴜʟʟ ᴏꜰ ᴘᴇʀɪʟ, ᴘᴏᴡᴇʀ-ᴜᴘꜱ, ᴀɴᴅ ᴜɴᴋɴᴏᴡɴꜱ ɪɴ ᴀ ʀᴏɢᴜᴇʟɪᴛᴇ ᴀᴅᴠᴇɴᴛᴜʀᴇ.                                                                               

https://www.runebound.io/
https://t.me/PlayRunebound
https://twitter.com/PlayRunebound
https://streamable.com/r512qx

*/

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.24;
import "./TestLib.sol";
contract nameFacet {
    function name() public view virtual returns (string memory) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds._name;
    }
}
