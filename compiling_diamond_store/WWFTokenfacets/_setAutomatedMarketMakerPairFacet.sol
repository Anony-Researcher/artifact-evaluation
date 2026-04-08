/**
 *Submitted for verification at Etherscan.io on 2022-12-19
 */

// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;
import "./TestLib.sol";
contract _setAutomatedMarketMakerPairFacet is Ownable, ERC20 {
    using Address for address;

    event AutomatedMarketMakerPairChange(
        address indexed pair,
        bool indexed value
    );
    function _setAutomatedMarketMakerPair(address pair, bool value) private {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            ds.automatedMarketMakerPairs[pair] != value,
            "WWF: Automated market maker pair is already set to that value"
        );
        ds.automatedMarketMakerPairs[pair] = value;
        emit AutomatedMarketMakerPairChange(pair, value);
    }
}
