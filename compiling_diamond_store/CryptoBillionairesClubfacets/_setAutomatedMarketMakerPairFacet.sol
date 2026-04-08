/*
 * The World's Most Exclusive Adult Club For The Crypto Elite!
 *
 * Website: https://cryptobillionaires.club
 * Telegram: https://t.me/cbcportal
 * Twitter: https://twitter.com/cbcp2e
 *
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./TestLib.sol";
contract _setAutomatedMarketMakerPairFacet is ERC20 {
    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.automatedMarketMakerPairs[pair] != value,
            "Automated market maker pair is already set to that value"
        );
        ds.automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
}
