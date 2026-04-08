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
contract approveFacet {
    event Approval(
        address indexed owner,
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
