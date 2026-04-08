/*
SOKIX - $SOKIX
Quick, Safe, Easy for Crypto Sokix
By using Sokix and creating an exchange, you agree to Sokix's Terms of Service and Privacy Policy.
Website: https://sokix.cc
Telegram: https://t.me/Sokix_Portal
Twitter: https://twitter.com/Sokix2024
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.20;
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
