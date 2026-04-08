/*
Ready to deploy the new ERC-314?

Website: https://www.forge314.com/
Whitepaper: https://docs.forge314.com/
Twitter: https://twitter.com/forge314
Telegram Portal: https://t.me/forge314
Telegram Deployer Bot: https://t.me/Forge314Bot

*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.16;
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
