/**
███████╗░██████╗░█████╗░██████╗░░█████╗░░██╗░░░░░░░██╗  ░█████╗░██╗
██╔════╝██╔════╝██╔══██╗██╔══██╗██╔══██╗░██║░░██╗░░██║  ██╔══██╗██║
█████╗░░╚█████╗░██║░░╚═╝██████╔╝██║░░██║░╚██╗████╗██╔╝  ███████║██║
██╔══╝░░░╚═══██╗██║░░██╗██╔══██╗██║░░██║░░████╔═████║░  ██╔══██║██║
███████╗██████╔╝╚█████╔╝██║░░██║╚█████╔╝░░╚██╔╝░╚██╔╝░  ██║░░██║██║
╚══════╝╚═════╝░░╚════╝░╚═╝░░╚═╝░╚════╝░░░░╚═╝░░░╚═╝░░  ╚═╝░░╚═╝╚═╝

Web:  https://www.aiescrowtech.com
Dapp: https://app.aiescrowtech.com
Bot:  https://t.me/VaultEscrowBot


X:    https://x.com/escrowaitech
TG:   https://t.me/escrowaitech

WhitePaper: https://whiltepaper.aiescrowtech.com
**/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.21;
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
