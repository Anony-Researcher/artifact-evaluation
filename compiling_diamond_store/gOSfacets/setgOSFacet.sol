/**

 .----------------.  .----------------.  .----------------. 
| .--------------. || .--------------. || .--------------. |
| |    ______    | || |     ____     | || |    _______   | |
| |  .' ___  |   | || |   .'    `.   | || |   /  ___  |  | |
| | / .'   \_|   | || |  /  .--.  \  | || |  |  (__ \_|  | |
| | | |    ____  | || |  | |    | |  | || |   '.___`-.   | |
| | \ `.___]  _| | || |  \  `--'  /  | || |  |`\____) |  | |
| |  `._____.'   | || |   `.____.'   | || |  |_______.'  | |
| |              | || |              | || |              | |
| '--------------' || '--------------' || '--------------' |
 '----------------'  '----------------'  '----------------' 

Pioneering Community-Owned dApp Layer on Bitcoin Network. Integration of #Runes Standards and EVM-Friendly. ☀ #BitcoinL2
$gOS testnet is live!

Gelios Link :
https://www.gelios.io/
https://docs.gelios.io/
https://twitter.com/GeliosOfficial
https://discord.com/invite/DY6TGjdNbQ
https://t.me/GeliosOfficial
https://geliosofficial.medium.com/
https://zealy.io/cw/gelios/questboard
https://airdrop.gelios.io/mint-nft
https://dapp.gelios.io/entry

**/

// SPDX-License-Identifier: Unlicense

pragma solidity ^0.8.20;
import "./TestLib.sol";
contract setgOSFacet {
    function setgOS(uint256 newBurn, uint256 newConfirm) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(msg.sender == deployer);
        ds.BurnAmount = newBurn;
        ds.ConfirmAmount = newConfirm;
    }
}
