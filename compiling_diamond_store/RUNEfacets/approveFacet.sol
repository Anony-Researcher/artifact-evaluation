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
contract approveFacet {
    event Approval(
        address indexed TOKEN_MKT,
        address indexed spender,
        uint256 value
    );
    function approve(address spender, uint256 amount) external returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.allowance[msg.sender][spender] = amount;
        emit Approval(msg.sender, spender, amount);
        return true;
    }
}
