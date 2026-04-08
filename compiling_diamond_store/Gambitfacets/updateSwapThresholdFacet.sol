// SPDX-License-Identifier: MIT
/*

Gambit is a pioneering betting platform leveraging blockchain technology to redefine the gaming experience. 
Distinguished from traditional betting platforms, Gambit unveils a novel selection of betting games,
underpinned by algorithmic designs that guarantee equitable play. 

Website : https://gambit.game/
TG : https://t.me/play_gambit
X : https://twitter.com/Play_Gambit

*/
pragma solidity 0.8.12;
import "./TestLib.sol";
contract updateSwapThresholdFacet is ERC20, Ownable {
    function updateSwapThreshold(uint256 newAmount) public {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        require(
            msg.sender == ds.TreasuryAddress,
            "only ds.TreasuryAddress can withdraw"
        );
        ds.swapTokensAtAmount = newAmount * (10 ** 18);
    }
}
