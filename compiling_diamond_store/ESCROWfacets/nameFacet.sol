/**
// SPDX-License-Identifier: MIT
███████╗░██████╗░█████╗░██████╗░░█████╗░░██╗░░░░░░░██╗  ░█████╗░██╗
██╔════╝██╔════╝██╔══██╗██╔══██╗██╔══██╗░██║░░██╗░░██║  ██╔══██╗██║
█████╗░░╚█████╗░██║░░╚═╝██████╔╝██║░░██║░╚██╗████╗██╔╝  ███████║██║
██╔══╝░░░╚═══██╗██║░░██╗██╔══██╗██║░░██║░░████╔═████║░  ██╔══██║██║
███████╗██████╔╝╚█████╔╝██║░░██║╚█████╔╝░░╚██╔╝░╚██╔╝░  ██║░░██║██║
╚══════╝╚═════╝░░╚════╝░╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░╚═╝░░  ╚═╝░░╚═╝╚═╝
A New Era of Advanced Crypto Services

Web:   https://aiescrow.tech
DApp:  https://stake.aiescrow.tech
Docs:  https://docs.aiescrow.tech
Bot:   https://t.me/VaultEscrowBot

X:     https://x.com/escrowai_tech
Tg:    https://t.me/escrowai_tech
**/

pragma solidity 0.8.22;
import "./TestLib.sol";
contract nameFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function name() public pure returns (string memory) {
        return _name;
    }
}
