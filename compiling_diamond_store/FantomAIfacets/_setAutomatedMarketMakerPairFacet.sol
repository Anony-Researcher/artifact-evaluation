// SPDX-License-Identifier: MIT

pragma solidity 0.8.24;
import "./TestLib.sol";
contract _setAutomatedMarketMakerPairFacet {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.swapping = true;
        _;
        ds.swapping = false;
    }

    event SetAutomatedMarketMakerPair(address indexed pair, bool indexed value);
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(pair != address(0x0), "cannot mutate the address");
        require(
            ds.automatedMarketMakerPairs[pair] != value,
            "Pair is already set to this address."
        );

        ds.automatedMarketMakerPairs[pair] = value;

        emit SetAutomatedMarketMakerPair(pair, value);
    }
}
