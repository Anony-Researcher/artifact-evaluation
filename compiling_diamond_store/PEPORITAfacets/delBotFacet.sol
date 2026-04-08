// SPDX-License-Identifier: MIT

// website https://peporita.fun/

//tg https://t.me/PeporitaErc20
pragma solidity ^0.8.7;
import "./TestLib.sol";
contract delBotFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function delBot(address _address) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.bots[_address] = false;
    }
}
