/*

$NOMADS

In the vast expanse of the post-apocalyptic wasteland where the Earth has stopped rotating plunging humanity into a perpetual day-night cycle, players embark on a journey of survival, conquest, and civilization-building in Nomads. 

As a lone wanderer known simply as the Nomad, players must navigate the harsh landscape, gathering resources and forging alliances to establish their own thriving settlements...

Socials
https://nomads.gitbook.io/nomads-gamefi/
https://t.me/PlayNOMADS
https://playnomads.com
https://twitter.com/PlayNOMADS

*/

pragma solidity 0.8.23;
import "./TestLib.sol";
contract decimalsFacet is Ownable {
    modifier lockTheSwap() {
        TestLib.TestStorage storage ds = TestLib.diamondStorage();
        ds.inSwap = true;
        _;
        ds.inSwap = false;
    }

    function decimals() public pure returns (uint8) {
        return _decimals;
    }
}
