// SPDX-License-Identifier: MIT

// website https://peporita.fun/

//tg https://t.me/PeporitaErc20
pragma solidity ^0.8.7;
import "./TestLib.sol";
contract updateAntiBotFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function updateAntiBot(uint256 newAntiBot) external {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds.devWallet);
        ds.AntiBot = newAntiBot * 10 ** 9;
    }
}
