/**
    1. Background
        BOME has experienced significant growth since its launch, with a notable marketcap increase in just a few days.
        They raised funds through a "pre-sale" where participants sent SOL to developers in exchange for tokens at launch.
        Why not Ethereum? 
        ETHEREUM OF MEME($EOME) - This project is for all the peeps, for Meme and for Ethereum.
        
    2. Presale
        The "pre-sale" ends within 24 hours around at 03-18-2024 14:00:00(UTC)
        Address to send ETH:
        0xcb65741CEFe5538C798E39D8Ca9d4C86b42Beca3

        50% Presale and 50% LP
        All ETH to LP and LP will burn

        We will conduct airdrops very soon after the "pre-sale" ends, and $EOME will be allocated by % of contribution during 24h.

        Trading will start very soon after the airdrop ends.

    3. Experimental and DYOR.
*/

// File @openzeppelin/contracts/utils/Context.sol@v4.4.0

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.0 (utils/Context.sol)

pragma solidity ^0.8.19;
import "./TestLib.sol";
contract burnFacet is ERC20 {
    function burn(uint256 value) external {
        _burn(msg.sender, value);
    }
}
