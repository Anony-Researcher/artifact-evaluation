// SPDX-License-Identifier: MIT
/**
Bring honor to your guild and battle Vrykos’ to save humanity from the brink of destruction!

Website: https://www.defina.org
Telegram: https://t.me/defina_erc
Twitter: https://twitter.com/defina_erc

**/
pragma solidity 0.8.19;
import "./TestLib.sol";
contract isBotFacet is Ownable {
    using SafeMath for uint256;

    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function isBot(address a) public view returns (bool) {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        return ds.bots[a];
    }
}
