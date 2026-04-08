// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.19;
import "./TestLib.sol";
contract _setAutomatedMarketMakerPairFacet is ERC20, Ownable {
    using SafeMath for uint256;

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
}
